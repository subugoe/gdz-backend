# encoding: utf-8
require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), 'config', 'environment'))
require 'logger'
require 'open-uri'
require 'uri'
require 'net/http'
require 'nokogiri'
require 'rdf/vocab'
require 'benchmark'
require 'oai'
require 'set'


class Ingest

  def initialize
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG

    Benchmark.bm(7) do |x|

      set = getIdsViaOAI()

      x.report("processMetsFile:") {
        processMetsFiles(set)
      }
    end

  end


  def getIdsViaOAI

    set    = Set.new
    client = OAI::Client.new 'http://gdz.sub.uni-goettingen.de/oai2'

    records = client.list_records

    records.each do |record|

      id = record.header.identifier
      i  = id.rindex(':')
      s  = id[i+1..-1]
      s.insert(0, 'PPN') unless s.start_with? "PPN"
      str = s[0..11]

      set.add(str)

    end

    return set
  end

  def processMetsFiles(set)


    set.each do |id|

      puts id

      @ppn     = id


      # file based
      #@mets_uri =  "PPN599457120.xml"
      #@doc      = File.open(@mets_uri) { |f| Nokogiri::XML(f) }

      # url based
      # mets_uri     = "http://gdz.sub.uni-goettingen.de/mets_export.php?PPN=PPN599457120"
      mets_uri = "http://gdz.sub.uni-goettingen.de/mets/#{@ppn}.xml"
      begin
        @doc       = Nokogiri::XML(open(mets_uri))
        @mets_path = "tmp_data/#{@ppn}.xml"
      rescue
        @logger.debug("problems to open file #{mets_uri} for #{@ppn}")
        next
      end

      next unless structureOk?

      File.write(@mets_path, @doc.to_xml)

      @recordIdentifier = getIdentifier()


      work = updateOrCreateWork


      createFileSets(work)

      File.delete(@mets_path)

    end


  end

  def structureOk?

    structype = @doc.xpath("//mets:structMap[@TYPE='PHYSICAL']")

    if (structype.empty?)
      @logger.debug("problems with structype for #{@ppn}")
      return false
    end

    return true

  end

  def createCollection(colname)

    begin
      col = Collection.find(colname)
    rescue # ActiveFedora::ObjectNotFoundError
      # if (col == nil)
      col       = Collection.new(colname)
      col.title = colname
      # end
    end

    return col

  end

  def updateOrCreateWork

    Benchmark.bm(7) do |x|


      x.report("updateOrCreateWork:") {


        begin
          bw = BibliographicWork.find("#{@recordIdentifier}_work")
          bw.delete(:eradicate => true)
          bw = BibliographicWork.new(id: "#{@recordIdentifier}_work")
        rescue
          bw = BibliographicWork.new(id: "#{@recordIdentifier}_work")
        end


        mods = @doc.xpath('//mods:mods', 'mods' => 'http://www.loc.gov/mods/v3')[0]


        # todo check multiple occurences of terms?
        # todo check problems with relatedItems

        # TODO check relatedItem (e.g. with Journals)

        # Strukturtyp
        begin
          bw.structype = @doc.xpath("//mets:structMap[@TYPE='LOGICAL']/mets:div/@TYPE", 'mets' => 'http://www.loc.gov/METS/').first.value
        rescue
          bw.structype = nil
          @logger.debug("structype is nil for #{@ppn}")
        end

        # Titel
        begin
          bw.title = mods.xpath('//mods:title', 'mods' => 'http://www.loc.gov/mods/v3')[0].text
        rescue
          bw.title = nil
          @logger.debug("title is nil for #{@ppn}")
        end

        # Autor
        begin
          roleTerm = mods.xpath('//mods:roleTerm[@type="code"]', 'mods' => 'http://www.loc.gov/mods/v3').text
          if (roleTerm == "aut")
            parent     = mods.xpath('//mods:roleTerm[@type="code"]/../..', 'mods' => 'http://www.loc.gov/mods/v3')
            bw.creator = parent.xpath('//mods:displayForm', 'mods' => 'http://www.loc.gov/mods/v3').text
          end
        rescue
          bw.creator = nil
          @logger.debug("creator is nil for #{@ppn}")
        end


        # Erscheinungsjahr
        begin
          dateIssued     = mods.xpath('//mods:dateIssued', 'mods' => 'http://www.loc.gov/mods/v3')[0].text
          bw.dateCreated = dateIssued
        rescue
          bw.dateCreated = nil
          @logger.debug("dateCreated is nil for #{@ppn}")
        end


        # Erscheinungsort
        begin
          placeTerm        = mods.xpath('//mods:placeTerm', 'mods' => 'http://www.loc.gov/mods/v3')[0].text
          bw.placeOfOrigin = placeTerm
        rescue
          bw.placeOfOrigin = nil
          @logger.debug("placeOfOrigin is nil for #{@ppn}")
        end


        # Verlag
        begin
          roleTerm = mods.xpath('//mods:roleTerm[@type="code"]', 'mods' => 'http://www.loc.gov/mods/v3').text
          if (roleTerm == "edt")
            parent       = mods.xpath('//mods:roleTerm[@type="code"]/../..', 'mods' => 'http://www.loc.gov/mods/v3')
            bw.publisher = parent.xpath('//mods:displayForm', 'mods' => 'http://www.loc.gov/mods/v3').text
          end
        rescue
          bw.publisher = nil
          @logger.debug("publisher is nil for #{@ppn}")
        end

        # todo put in default collectionm if no classification is set
        # Kollektionen
        begin
          classification    = mods.xpath('//mods:classification', 'mods' => 'http://www.loc.gov/mods/v3').text
          bw.classification = classification
          col               = createCollection(classification)
          addToMembers(col, bw)
        rescue
          @logger.debug("no classification set for #{@ppn}")
        end


        # todo Gescannte Seiten


        # PPN (original)
        begin
          identifier    = @doc.xpath('//mods:mods[1]/mods:identifier[@type="PPNanalog"]', 'mods' => 'http://www.loc.gov/mods/v3').text
          bw.identifier = identifier
        rescue
          bw.identifier = nil
          @logger.debug("identifier is nil for #{@ppn}")
        end


        # PPN (digital):
        begin
          bw.recordIdentifier = @recordIdentifier
        rescue
          bw.recordIdentifier = nil
          @logger.debug("recordIdentifier is nil for #{@ppn}")
        end


        # PURL
        begin
          #purl    = @doc.xpath("//mets:structMap[@TYPE='LOGICAL']/mets:div/@CONTENTIDS", 'mets' => 'http://www.loc.gov/METS/').first.value
          bw.purl = "http://resolver.sub.uni-goettingen.de/purl?#{@ppn}"
        rescue
          bw.purl = nil
          @logger.debug("purl is nil for #{@ppn}")
        end

        # todo sub opac


        # Physical Description
        begin
          physicalDescription    = mods.xpath('//mods:physicalDescription/mods:extent', 'mods' => 'http://www.loc.gov/mods/v3').text
          bw.physicalDescription = physicalDescription
        rescue
          bw.physicalDescription = nil
          @logger.debug("physicalDescription is nil for #{@ppn}")
        end


        # Language
        begin
          languageTerm    = mods.xpath('//mods:languageTerm', 'mods' => 'http://www.loc.gov/mods/v3').text
          bw.languageTerm = languageTerm
        rescue
          bw.languageTerm = nil
          @logger.debug("languageTerm is nil for #{@ppn}")
        end

        bw.save

        return bw
      }
    end
  end

  def createFileSets(work)

    Benchmark.bm(7) do |x|
      x.report("createBiblFileSets:") {
        biblfileset = createBiblFileSets(work)
      }

      x.report("createPageFileSets:") {
        pageFileSet = createPageFileSets(work)
      }

      x.report("createMetsFileSets:") {
        metsFileSet = createMetsFileSets(work)
      }

    end
  end

  def createBiblFileSets(work)

    i = 0

    @biblFileSets = Hash.new

    pageDivs = @doc.xpath("//mets:structMap[@TYPE='LOGICAL']//mets:div", 'mets' => 'http://www.loc.gov/METS/')

    pageDivs.each do |pageDiv|

      myorder = i
      label   = pageDiv.attributes["LABEL"]
      type    = pageDiv.attributes["TYPE"]

      begin
        bfs = BibliographicFileSet.find("#{@recordIdentifier}_logical_#{myorder}")
        bfs.delete(:eradicate => true)
        bfs = BibliographicFileSet.new(id: "#{@recordIdentifier}_logical_#{myorder}")
      rescue
        bfs = BibliographicFileSet.new(id: "#{@recordIdentifier}_logical_#{myorder}")
      end


      bfs.label       = label.nil? ? nil : label.value
      bfs.logicaltype = type.nil? ? nil : type.value
      bfs.order       = myorder

      bfs.save


      work.members << bfs
      work.save

      # todo via background processing? put in redis and find via id at processing time
      @biblFileSets[i] = bfs

      i = i+1

    end

    #    return bfs

  end

  def createPageFileSets(work)

    i = 0

    pageDivs = @doc.xpath("//mets:structMap[@TYPE='PHYSICAL']/mets:div/mets:div", 'mets' => 'http://www.loc.gov/METS/')

    pageDivs.each do |pageDiv|

      order      = pageDiv.attributes["ORDER"]
      orderlabel = pageDiv.attributes["ORDERLABEL"]
      type       = pageDiv.attributes["TYPE"]


      begin
        pfs = MetsFileSet.find("#{@recordIdentifier}_page_#{order}")
        pfs.delete(:eradicate => true)
        pfs = PageFileSet.new(id: "#{@recordIdentifier}_page_#{order}")
      rescue
        pfs = PageFileSet.new(id: "#{@recordIdentifier}_page_#{order}")
      end


      pfs.order      = order.nil? ? nil : order.value
      pfs.orderlabel = orderlabel.nil? ? nil : orderlabel.value
      pfs.pagetype   = type.nil? ? nil : type.value
      #pfs.save

      order          = pfs.order.to_i

      if (order < 10)
        phys_id = "PHYS_000#{order}"
      elsif (order < 100)
        phys_id = "PHYS_00#{order}"
      elsif (order < 1000)
        phys_id = "PHYS_0#{order}"
      else
        phys_id = "PHYS_#{order}"
      end

      links = @doc.xpath("//mets:structLink/mets:smLink[@xlink:to='#{phys_id}']/@xlink:from", {'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink'})
      links.each do |link|
        j = link.value.split("_")[1].to_i
        @biblFileSets[j].members << pfs
        @biblFileSets[j].save
      end


      # todo add the files


      fptrs = pageDivs[0].xpath("mets:fptr", 'mets' => 'http://www.loc.gov/METS/')
      fptrs.each do |fptr|
        id = fptr.attributes["FILEID"].value


        file = @doc.xpath("//mets:fileSec/mets:fileGrp/mets:file[@ID='#{id}']", {'mets' => 'http://www.loc.gov/METS/'}).first

        mimetype = file.attributes["MIMETYPE"].value
        use      = file.parent.attributes["USE"].value

        flocate = file.xpath("mets:FLocat", {'mets' => 'http://www.loc.gov/METS/'})
        href    = flocate.xpath("@xlink:href", {'xlink' => 'http://www.w3.org/1999/xlink'}).first.value
        #href     = file.children[1].attributes["href"].value

        # todo for now process just PRESENTATION, THUMBS, GDZOCR resolutions/derivated files should be created by IIIF
        # LOCAL is file-based
        scheme  = URI(href).scheme

        if (use == "PRESENTATION")

          begin
            if (scheme == "http")
              file1 = open(href, "r")
            elsif (scheme == "file")
              file1 = open(href.path)
            end

            Hydra::Works::UploadFileToFileSet.call(pfs, file1)
#            pfs.save
            f1           = pfs.files.first
            f1.mime_type = mimetype
            pfs.create_derivatives # generates a thumb
            pfs.save
          rescue
            @logger.debug("could not open file #{href} for #{@ppn} (#{use})")
            break
          end

          #elsif (use == "THUMBS")

          #elsif (use == "GDZOCR")

        end

      end


      work.members << pfs
      work.save


      i = i+1

    end

#    return pf

  end

  def createMetsFileSets(work)

    begin
      mfs = MetsFileSet.find("#{@recordIdentifier}_mets")
      mfs.delete(:eradicate => true)
      mfs = MetsFileSet.new(id: "#{@recordIdentifier}_mets")
    rescue
      mfs = MetsFileSet.new(id: "#{@recordIdentifier}_mets")
    end


    # todo retrieve version from mets doc
    mfs.metsVersion = 1
    mfs.modsVersion = 1

    begin
      Hydra::Works::UploadFileToFileSet.call(mfs, open(@mets_path))

      f           = mfs.files.first
      f.mime_type = 'application/xml'
    rescue
      @logger.debug("could not open file #{@mets_path} for #{@ppn}")
    end

    mfs.save

    work.members << mfs
    work.save

    return mfs

  end


  def createPage

  end

  def createDerivates

  end

  def addToMembers(collection, element)
    contained = collection.members.select { |m| m.id == element.id }

    if contained.empty?
      collection.members << element
      collection.save
    end
  end

  def getIdentifier()

    begin
      identifier = @doc.xpath('//mods:mods[1]/mods:identifier[@type="gbv-ppn"]', 'mods' => 'http://www.loc.gov/mods/v3').text
      return identifier if identifier != ""
    rescue
    end

    begin
      identifier = @doc.xpath('//mods:mods[1]/mods:recordInfo/mods:recordIdentifier[@source="gbv-ppn"]', 'mods' => 'http://www.loc.gov/mods/v3').text
      return identifier if identifier != ""
    rescue
    end

    begin
      identifier = @doc.xpath('//mods:mods[1]/mods:identifier[@type="ppn" or @type="PPN"]', 'mods' => 'http://www.loc.gov/mods/v3').text
      return identifier if identifier != ""
    rescue
    end

    begin
      identifier = @doc.xpath('//mods:mods[1]/mods:identifier[@type="urn" or @type="URN"]', 'mods' => 'http://www.loc.gov/mods/v3').text
      return identifier if identifier != ""
    rescue
    end

    return nil
  end

end


Ingest.new