require 'nokogiri'
require 'open-uri'
require 'redis-semaphore'
require 'helper/global_helper'


class ProcessMetsFileSetHelper
  include GlobalHelper

  def initialize(ppn, work_id)
    @s            = Redis::Semaphore.new(:semaphore_name, :host => "redis")
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG

    @work_id = work_id
    @ppn     = ppn
  end

  def createMetsFileSets

    mfs   = nil
    fs_id = "#{@ppn}_mets"

    @s.lock do
      begin
        mfs = MetsFileSet.where(recordIdentifier: "#{fs_id}").first
        mfs.delete(:eradicate => true) if mfs != nil
        mfs = MetsFileSet.create() do |fs|
          fs.recordIdentifier = fs_id
        end

      rescue ActiveFedora::ObjectNotFoundError => e
        mfs = MetsFileSet.create() do |fs|
          fs.recordIdentifier = fs_id
        end

        @logger.debug("new MetsFileSet #{fs_id} created")
      rescue Exception => e
        @logger.debug("Exception (#{e.message}) while MetsFileSet creation for '#{fs_id}'")
      end
    end

    # todo retrieve version from mets doc
    mfs.metsVersion = 1
    mfs.modsVersion = 1

    begin
      @s.lock do
        Hydra::Works::UploadFileToFileSet.call(mfs, open(metsPath()))
      end

      f           = mfs.files.first
      f.mime_type = 'application/xml'
    rescue Exception => e
      @logger.debug("could not open file #{metsPath()} for #{@ppn}")
    end

    @s.lock do
      mfs.save
    end

    addMemberToWork(mfs)

    return mfs

  end

end