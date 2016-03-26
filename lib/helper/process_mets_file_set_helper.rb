require 'nokogiri'
require 'open-uri'
require 'redis-semaphore'


class ProcessMetsFileSetHelper
  include GlobalHelper

  def initialize(ppn, work_id)
    @s            = Redis::Semaphore.new(:semaphore_name, :host => "192.168.99.100")
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG

    @work_id = work_id
    @ppn     = ppn
  end

  def createMetsFileSets

    mfs = nil

    @s.lock do
      begin
        mfs = MetsFileSet.find("#{@ppn}_mets")
        mfs.delete(:eradicate => true)
        mfs = MetsFileSet.create(id: "#{@ppn}_mets")
      rescue Exception => e
        mfs = MetsFileSet.create(id: "#{@ppn}_mets")
      end
    end

    # todo retrieve version from mets doc
    mfs.metsVersion = 1
    mfs.modsVersion = 1

    begin
      Hydra::Works::UploadFileToFileSet.call(mfs, open(metsPath()))
      f           = mfs.files.first
      f.mime_type = 'application/xml'
    rescue Exception => e
      @logger.debug("could not open file #{metsPath()} for #{@ppn}")
    end

    @s.lock do
      mfs.save
    end


    begin
      @s.lock do
        work = BibliographicWork.find(@work_id)
        work.members << mfs
        work.save
      end
    rescue ActiveFedora::ObjectNotFoundError => e
      @logger.debug("BibliographicWork #{@work_id} not found, METS file could not be associated")
    rescue Exception => e
      @logger.debug("Exception (#{e.message}) while sind BibliographicWork '#{@work_id}'")
    end

    return mfs

  end

end