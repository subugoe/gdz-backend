require 'nokogiri'
require 'open-uri'
require 'redis-semaphore'
require 'helper/global_helper'


class ProcessBiblFileSetHelper
  include GlobalHelper

  def initialize(ppn, work_id)
    @s            = Redis::Semaphore.new(:semaphore_name, :host => "192.168.99.100")
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG

    @work_id = work_id
    @ppn     = ppn
  end

  def createBiblFileSets


    pageDivs = openDocFromPath.xpath("//mets:structMap[@TYPE='LOGICAL']//mets:div", 'mets' => 'http://www.loc.gov/METS/')

    pageDivs.each do |pageDiv|

      id    = pageDiv.attributes["ID"]
      label = pageDiv.attributes["LABEL"]
      type  = pageDiv.attributes["TYPE"]

      unless id.nil?
        id      = id.text
        j       = id.rindex('_')
        myorder = id[(j+1)..(id.length-1)].to_i
      else
        @logger.error("Some ID attribute ('mets:structMap[@TYPE='LOGICAL']//mets:div[@ID]') is nil")
        next
      end

      bfs    = nil
      bfs_id = "#{@ppn}_logical_#{myorder}"

      @s.lock do
        begin
          bfs = BibliographicFileSet.where(recordIdentifier: "#{bfs_id}").first
          bfs.delete(:eradicate => true)  if bfs != nil
          bfs = BibliographicFileSet.create() do |fs|
            fs.recordIdentifier = bfs_id
          end

        rescue ActiveFedora::ObjectNotFoundError => e
          bfs = BibliographicFileSet.create() do |fs|
            fs.recordIdentifier = bfs_id
          end
          @logger.debug("new BibliographicFileSet #{bfs_id} created")
        rescue Exception => e
          @logger.debug("Exception (#{e.message}) while BibliographicFileSet creation for '#{bfs_id}'")
        end
      end


      bfs.label       = label.nil? ? nil : label.value
      bfs.logicaltype = type.nil? ? nil : type.value
      bfs.order       = myorder

      @s.lock do
        bfs.save
      end

      addMemberToWork(bfs)

    end

  end

end