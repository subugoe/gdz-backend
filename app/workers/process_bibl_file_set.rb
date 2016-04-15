require 'helper/process_bibl_file_set_helper'

class ProcessBiblFileSet
  include Sidekiq::Worker

  sidekiq_options queue: :biblfileset, backtrace: true, retry: false

  def initialize
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end

  def perform(ppn, work_id)
    ProcessBiblFileSetHelper.new(ppn, work_id).createBiblFileSets
    @logger.info("Bibliographic file set created for #{ppn}")
  end

end