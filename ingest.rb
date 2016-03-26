# encoding: utf-8
require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), 'config', 'environment'))
require 'logger'
require 'open-uri'
require 'uri'
require 'net/http'
require 'nokogiri'
require 'rdf/vocab'
require 'benchmark'
require 'oai'
require 'set'


class Ingest

  GDZ_OAI_ENDPOINT   = "http://gdz.sub.uni-goettingen.de/oai2"
  DEFAULT_PROCESSING = "OAI"

  def initialize(cli_args)
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG


    @processing_type = (cli_args == 1) ? cli_args[0] : DEFAULT_PROCESSING
    @url             = (cli_args == 2) ? cli_args[1] : GDZ_OAI_ENDPOINT
    puts @gdz_oai_endpoint

    # todo add direktory and file based processing
    # if - else - elsif

    begin
      Collection.find("Testcollection")
    rescue ActiveFedora::ObjectNotFoundError => e
      Collection.create(id: "Testcollection")
    end

    enqueueIdsFromOAI()

  end


  def enqueueIdsFromOAI

    i        = 0
    client   = OAI::Client.new @url

    # Get the first page of identifiers
    response = client.list_identifiers.to_a

    # todo remove this
    catch (:stop) do

      response.each do |record|
        # todo remove this
        throw :stop if (i==5)
        enqueueInMetsQueue(parseId(record.identifier))
        i = i+1
      end


      # Get the other pages of identifiers
      while true do
        begin
          response = client.list_identifiers(:resumption_token => response.resumption_token)
          response.each do |record|
            enqueueInMetsQueue(parseId(record.identifier))
          end
        rescue Exception => e
          @logger.debug("problems to harvest metadata (identfiers) via oai")
          break
        end
      end

    end
  end


# e.g. oai:gdz.sub.uni-goettingen.de:PPN832796611
  def parseId(id)

    # todo collect problem id's and print them at the end

    i = id.rindex(':')
    #s = id[i+1..-1]
    #s.insert(0, 'PPN') unless s.start_with? "PPN"
    j = id.rindex('|')
    j ||= id.size
    s = id[(i+1)..(j-1)]
    return s #[0..11]
  end


  def enqueueInMetsQueue(ppn)
    ProcessMets.perform_async(ppn)
  end

end

Ingest.new(ARGV)