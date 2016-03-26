require 'nokogiri'
require 'open-uri'
require 'benchmark'
require 'redis-semaphore'
require 'helper/process_bibl_file_set_helper'

class ProcessBiblFileSet
  include Sidekiq::Worker

  sidekiq_options queue: :biblfileset, backtrace: true, retry: false

  def initialize
    @s            = Redis::Semaphore.new(:semaphore_name, :host => "192.168.99.100")
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end

  def perform(ppn)
    #@logger.info("ProcessMets #{ppn}")


    @s.lock do
      ProcessBiblFileSetHelper.new(ppn).processMetsFiles
    end


    @logger.info("METS for #{ppn} processed")
  end


end