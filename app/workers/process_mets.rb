require 'helper/process_mets_helper'

class ProcessMets
  include Sidekiq::Worker

  sidekiq_options queue: :mets, backtrace: true, retry: false

  def initialize
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end

  def perform(ppn)
    ProcessMetsHelper.new(ppn).processMetsFiles
    @logger.info("METS for #{ppn} processed")
  end


end