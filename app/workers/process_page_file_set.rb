require 'helper/process_page_file_set_helper'

class ProcessPageFileSet
  include Sidekiq::Worker

  sidekiq_options queue: :pagefileset, backtrace: true, retry: false

  def initialize
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end

  def perform(ppn, work_id)
    ProcessPageFileSetHelper.new(ppn, work_id).createPageFileSets
    @logger.info("Page file set created for #{ppn}")
  end

end