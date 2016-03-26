require 'nokogiri'
require 'open-uri'
require 'redis-semaphore'



class ProcessPageFileSetHelper


  def initialize(work_id, recordIdentifier)
    @s = Redis::Semaphore.new(:semaphore_name, :host => "192.168.99.100")
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG

    @work_id = work_id
    @recordIdentifier = recordIdentifier

  end

  def createPageFileSets(work_id, ppn)

    pageDivs = doc.xpath("//mets:structMap[@TYPE='PHYSICAL']/mets:div/mets:div", 'mets' => 'http://www.loc.gov/METS/')

    pageDivs.each do |pageDiv|

      order      = pageDiv.attributes["ORDER"]
      orderlabel = pageDiv.attributes["ORDERLABEL"]
      type       = pageDiv.attributes["TYPE"]


      begin
        pfs = PageFileSet.find("#{recordIdentifier}_page_#{order}")
        pfs.delete(:eradicate => true)
        pfs = PageFileSet.new(id: "#{recordIdentifier}_page_#{order}")
      rescue Exception => e
        pfs = PageFileSet.new(id: "#{recordIdentifier}_page_#{order}")
      end


      pfs.order      = order.nil? ? nil : order.value
      pfs.orderlabel = orderlabel.nil? ? nil : orderlabel.value
      pfs.pagetype   = type.nil? ? nil : type.value
      pfs.save

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

        bfs = BibliographicFileSet.find("#{recordIdentifier}_logical_#{j}")

        bfs.members << pfs
        bfs.save
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

            Hydra::Works::UploadFileToFileSet.call(pfs, file1)

            f1           = pfs.files.first
            f1.mime_type = mimetype
            pfs.create_derivatives # generates a thumb
            pfs.save

          rescue Exception => e
            @logger.debug("could not open file #{href} for #{@ppn} (#{use})")
            break
          end

          #elsif (use == "THUMBS")

          #elsif (use == "GDZOCR")

        end

      end


      work.members << pfs
      work.save

    end

  end

end