require 'helper/process_collection_helper'

class ProcessCollection
  include Sidekiq::Worker

  sidekiq_options queue: :collection, backtrace: true, retry: false

  def initialize
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end

  def perform(ppn, work_id, classification)
    ProcessCollectionHelper.new(ppn, work_id, classification).createCollection
    @logger.info("Collection for #{ppn} processed")
  end

end