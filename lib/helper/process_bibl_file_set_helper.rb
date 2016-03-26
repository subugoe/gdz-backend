require 'nokogiri'
require 'open-uri'
require 'redis-semaphore'


class ProcessBiblFileSetHelper


  def initialize
    @s = Redis::Semaphore.new(:semaphore_name, :host => "192.168.99.100")

  end

  def createBiblFileSets(work_id, ppn)

    myorder = 0


    pageDivs = doc.xpath("//mets:structMap[@TYPE='LOGICAL']//mets:div", 'mets' => 'http://www.loc.gov/METS/')

    pageDivs.each do |pageDiv|

      label = pageDiv.attributes["LABEL"]
      type  = pageDiv.attributes["TYPE"]

      begin
        bfs = BibliographicFileSet.find("#{recordIdentifier}_logical_#{myorder}")
        bfs.delete(:eradicate => true)
        bfs = BibliographicFileSet.new(id: "#{recordIdentifier}_logical_#{myorder}")
      rescue Exception => e
        bfs = BibliographicFileSet.new(id: "#{recordIdentifier}_logical_#{myorder}")
      end


      bfs.label       = label.nil? ? nil : label.value
      bfs.logicaltype = type.nil? ? nil : type.value
      bfs.order       = myorder
      bfs.save


      work.members << bfs
      work.save


      myorder = myorder + 1

    end


  end

end