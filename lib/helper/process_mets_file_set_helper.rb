require 'nokogiri'
require 'open-uri'
require 'benchmark'


class ProcessMetsFileSetHelper
  include GlobalHelper

  def initialize(work_id, ppn)
    @semaphore    = Mutex.new
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG

    @work_id = work_id
    @ppn = ppn

  end

  def createMetsFileSets

    begin
      mfs = MetsFileSet.find("#{@ppn}_mets")
      mfs.delete(:eradicate => true)
      mfs = MetsFileSet.new(id: "#{@ppn}_mets")
    rescue Exception => e
      mfs = MetsFileSet.new(id: "#{@ppn}_mets")
    end


    # todo retrieve version from mets doc
    mfs.metsVersion = 1
    mfs.modsVersion = 1

    begin
      Hydra::Works::UploadFileToFileSet.call(mfs, open(metsPath(@recordIdentifier)))

      f           = mfs.files.first
      f.mime_type = 'application/xml'
    rescue Exception => e
      @logger.debug("could not open file #{metsPath(@recordIdentifier)} for #{@recordIdentifier}")
    end

    mfs.save

    work.members << mfs
    work.save

    return mfs

  end

end