require 'nokogiri'
require 'open-uri'
require 'benchmark'
require 'helper/process_mets_file_set_helper'

class ProcessMetsFileSet
  include Sidekiq::Worker

  sidekiq_options queue: :metsfileset, backtrace: true, retry: false

  def initialize
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end

  def perform(ppn, work_id)
    ProcessMetsFileSetHelper.new(ppn, work_id).createMetsFileSets
    @logger.info("METS file set created for #{ppn}")
  end

end