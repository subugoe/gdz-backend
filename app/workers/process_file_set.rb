require 'helper/process_mets_file_set_helper'
require 'helper/process_page_file_set_helper'
require 'helper/process_bibl_file_set_helper'

class ProcessFileSet
  include Sidekiq::Worker

  sidekiq_options queue: :fileset, backtrace: true, retry: false

  def initialize
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end

  def perform(ppn, work_id)
    ProcessMetsFileSetHelper.new(ppn, work_id).createMetsFileSets
    @logger.info("METS file set created for #{ppn}")

    ProcessBiblFileSetHelper.new(ppn, work_id).createBiblFileSets
    @logger.info("Bibliographic file set created for #{ppn}")

    ProcessPageFileSetHelper.new(ppn, work_id).createPageFileSets
    @logger.info("Page file set created for #{ppn}")

  end

end