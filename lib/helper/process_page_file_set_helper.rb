require 'nokogiri'
require 'open-uri'
require 'redis-semaphore'
require 'helper/global_helper'


class ProcessPageFileSetHelper
  include GlobalHelper


  def initialize(ppn, work_id)
    @s            = Redis::Semaphore.new(:page_file_set_semaphore, :host => "redis")
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG

    @work_id = work_id
    @ppn     = ppn
  end

  def createPageFileSets

    doc = openDocFromPath()

    pageDivs = doc.xpath("//mets:structMap[@TYPE='PHYSICAL']/mets:div/mets:div", 'mets' => 'http://www.loc.gov/METS/')

    pageDivs.each do |pageDiv|

      order      = pageDiv.attributes["ORDER"]
      orderlabel = pageDiv.attributes["ORDERLABEL"]
      type       = pageDiv.attributes["TYPE"]


      pfs    = nil
      pfs_id = "#{@ppn}_page_#{order}"


      @s.lock do
        begin
          pfs = PageFileSet.where(recordIdentifier: "#{pfs_id}").first
          pfs.delete(:eradicate => true) if pfs != nil
          pfs = PageFileSet.create() do |fs|
            fs.recordIdentifier = pfs_id
          end
        rescue ActiveFedora::ObjectNotFoundError => e
          pfs = PageFileSet.create() do |fs|
            fs.recordIdentifier = pfs_id
          end
          @logger.debug("new PageFileSet #{pfs_id} created")
        rescue Exception => e
          @logger.debug("Exception (#{e.message}) while PageFileSet creation for '#{pfs_id}'")
        end
      end

      pfs.order      = order.nil? ? nil : order.value
      pfs.orderlabel = orderlabel.nil? ? nil : orderlabel.value
      pfs.pagetype   = type.nil? ? nil : type.value

      @s.lock do
        pfs.save
      end

      order = pfs.order.to_i

      if (order < 10)
        phys_id = "PHYS_000#{order}"
      elsif (order < 100)
        phys_id = "PHYS_00#{order}"
      elsif (order < 1000)
        phys_id = "PHYS_0#{order}"
      else
        phys_id = "PHYS_#{order}"
      end

      links = doc.xpath("//mets:structLink/mets:smLink[@xlink:to='#{phys_id}']/@xlink:from", {'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink'})
      links.each do |link|
        j = link.value.split("_")[1].to_i

        # todo take care that BibliographicWork is processed before try to add pfs to bw
        addMemberToBibliographicWork(pfs, j)
      end


      # todo add the files


      fptrs = pageDivs[0].xpath("mets:fptr", 'mets' => 'http://www.loc.gov/METS/')
      fptrs.each do |fptr|
        id = fptr.attributes["FILEID"].value

        file = doc.xpath("//mets:fileSec/mets:fileGrp/mets:file[@ID='#{id}']", {'mets' => 'http://www.loc.gov/METS/'}).first

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

            @s.lock do
              Hydra::Works::UploadFileToFileSet.call(pfs, file1)
            end

            f1           = pfs.files.first
            f1.mime_type = mimetype
            pfs.create_derivatives # generates a thumb
            @s.lock do
              pfs.save
            end

          rescue Exception => e
            @logger.debug("could not open file #{href} for #{@ppn} (#{use})")
            break
          end

          # todo THUMBS
          #elsif (use == "THUMBS")

          # todo GDZOCR
          #elsif (use == "GDZOCR")

        end

      end

      addMemberToWork(pfs)

    end

  end

end