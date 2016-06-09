require 'nokogiri'
require 'open-uri'
require 'redis-semaphore'
require 'helper/global_helper'


class ProcessMetsHelper
  include GlobalHelper

  def initialize(ppn)
    @s = Redis::Semaphore.new(:mets_helper_setsemaphore, :host => "redis")

    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG

    @ppn = ppn
  end


  def processMetsFiles

    # todo check what is the better solution: use ppn or url from oai

    @doc = openDocFromUri()

    return unless structureOk?(@doc)

    createFile()

    @recordIdentifiers = getIdentifiers(@doc.xpath('//mods:mods[1]', 'mods' => 'http://www.loc.gov/mods/v3'))


    if (@recordIdentifiers.size == 0)
      @logger.debug("no record identifier found for #{@ppn}")
      return
    end

    #puts "---> recordIdentifier: #{recordIdentifiers[0]}"

    work = updateOrCreateWork()

    createFileSets(work.id)

    #fileDelete()

  end


  def structureOk?(doc)

    # todo differentiate collections and works

    structype = doc.xpath("//mets:structMap[@TYPE='PHYSICAL']")

    if (structype.empty?)
      @logger.debug("problems with structype for #{@ppn}")
      return false
    end

    return true

  end

  def createFileSets(work_id)

    enqueueInFilesetQueue(work_id)

    #enqueueInBiblFilesetQueue(work_id)
    #enqueueInMetsFilesetQueue(work_id)
    #enqueueInPageFilesetQueue(work_id)

  end


  def updateOrCreateWork

    # todo delete related objects and file sets
    # todo add additional related sources (TEI, OCR, external digitized Images)

    bw = nil

    @s.lock do

      begin
        bw = BibliographicWork.where(recordIdentifier: work_id).first

        bw.delete(:eradicate => true) if bw != nil
        #bw = BibliographicWork.new(id: work_id)

        bw = BibliographicWork.create() do |bw|
          bw.recordIdentifier = work_id
        end
          #bw.save

      rescue ActiveFedora::ObjectNotFoundError => e
        #bw = BibliographicWork.new(id: work_id)
        bw = bw = BibliographicWork.create() do |bw|
          bw.recordIdentifier = work_id
        end
        @logger.debug("create new BibliographicWork #{work_id}")
      rescue Exception => e
        @logger.debug("Exception (#{e.message}) in updateOrCreateWork for '#{work_id}'")
      end

    end

    mods = @doc.xpath('//mods:mods', 'mods' => 'http://www.loc.gov/mods/v3')[0]

    # todo check multiple occurences of terms?
    # todo check problems with relatedItems
    # TODO check relatedItem (e.g. with Journals)

    # Strukturtyp
    begin
      bw.structype = @doc.xpath("//mets:structMap[@TYPE='LOGICAL']/mets:div/@TYPE", 'mets' => 'http://www.loc.gov/METS/').first.value
    rescue Exception => e
      @logger.debug("structype is nil for #{@ppn}")
    end


    # Titel
    begin
      bw.title = mods.xpath('mods:titleInfo/mods:title', 'mods' => 'http://www.loc.gov/mods/v3')[0].text
    rescue Exception => e
      @logger.debug("title is nil for #{@ppn}")
    end


    # Autor
    begin
      roleTerm = mods.xpath('//mods:roleTerm[@type="code"]', 'mods' => 'http://www.loc.gov/mods/v3').text
      if (roleTerm == "aut")
        parent     = mods.xpath('//mods:roleTerm[@type="code"]/../..', 'mods' => 'http://www.loc.gov/mods/v3')
        bw.creator = parent.xpath('//mods:displayForm', 'mods' => 'http://www.loc.gov/mods/v3').text
      end
    rescue Exception => e
      @logger.debug("creator is nil for #{@ppn}")
    end

    # Erscheinungsjahr
    begin
      dateIssued     = mods.xpath('mods:originInfo/mods:dateIssued', 'mods' => 'http://www.loc.gov/mods/v3')[0].text
      bw.dateCreated = dateIssued
    rescue Exception => e
      puts e.message
      @logger.debug("dateCreated is nil for #{@ppn}")
    end

    # Erscheinungsort
    begin
      placeTerm        = mods.xpath('//mods:placeTerm', 'mods' => 'http://www.loc.gov/mods/v3')[0].text
      bw.placeOfOrigin = placeTerm
    rescue Exception => e
      puts e.message
      @logger.debug("placeOfOrigin is nil for #{@ppn}")
    end

    # Verlag
    begin
      roleTerm = mods.xpath('//mods:roleTerm[@type="code"]', 'mods' => 'http://www.loc.gov/mods/v3').text
      if (roleTerm == "edt")
        parent       = mods.xpath('//mods:roleTerm[@type="code"]/../..', 'mods' => 'http://www.loc.gov/mods/v3')
        bw.publisher = parent.xpath('//mods:displayForm', 'mods' => 'http://www.loc.gov/mods/v3').text
      end
    rescue Exception => e
      puts e.message
      @logger.debug("publisher is nil for #{@ppn}")
    end


    # todo put in default collectionm if no classification is set
    # Kollektionen
    begin
      classifications = mods.xpath('//mods:classification', 'mods' => 'http://www.loc.gov/mods/v3')

      # todo as Array
      classifications.each do |cl|
        bw.classifications << cl.text unless bw.classifications.include?(cl.text)
        enqueueInCollectionQueue(bw.id, cl.text)
      end
    rescue Exception => e
      @logger.debug("no classification set for #{@ppn}, collection not created")
    end


    # todo Gescannte Seiten

    # PPN (original)
    begin
      # todo differentiate the identifiertypes
      #identifier    = doc.xpath('//mods:mods[1]/mods:identifier[@type="PPNanalog"]', 'mods' => 'http://www.loc.gov/mods/v3').text
      ids = @recordIdentifiers[1..-1]
      ids.each do |id|
        bw.identifiers << id unless bw.identifiers.include?(id)
      end
    rescue Exception => e
      @logger.debug("identifier is nil for #{@ppn}")
    end


    # ppn (digital):
    begin
      bw.recordIdentifier = @recordIdentifiers[0]
    rescue Exception => e
      @logger.debug("recordIdentifier is nil for #{@ppn}")
    end

    # PURL
    begin
      #purl    = doc.xpath("//mets:structMap[@TYPE='LOGICAL']/mets:div/@CONTENTIDS", 'mets' => 'http://www.loc.gov/METS/').first.value
      bw.purl = "http://resolver.sub.uni-goettingen.de/purl?#{@ppn}"
    rescue Exception => e
      @logger.debug("purl is nil for #{@ppn}")
    end

    # todo sub opac


    # Physical Description
    begin
      physicalDescription    = mods.xpath('//mods:physicalDescription/mods:extent', 'mods' => 'http://www.loc.gov/mods/v3').text
      bw.physicalDescription = physicalDescription
    rescue Exception => e
      @logger.debug("physicalDescription is nil for #{@ppn}")
    end

    # Language
    begin
      languageTerm    = mods.xpath('//mods:languageTerm', 'mods' => 'http://www.loc.gov/mods/v3').text
      bw.languageTerm = languageTerm
    rescue Exception => e
      puts e.message
      @logger.debug("languageTerm is nil for #{@ppn}")
    end


    @s.lock do
      bw.save
    end
    return bw

  end


  def createPage

  end

  def createDerivates

  end


  def getIdentifiers(mods)

    arr = Array.new

    begin
      identifier = mods.xpath('mods:identifier[@type="gbv-ppn"]', 'mods' => 'http://www.loc.gov/mods/v3').text
      arr << identifier if identifier != ""
    rescue Exception => e
      @logger.debug("no identifier found with type gbv-ppn for #{@ppn}")
    end

    begin
      identifier = mods.xpath('mods:recordInfo/mods:recordIdentifier[@source="gbv-ppn"]', 'mods' => 'http://www.loc.gov/mods/v3').text
      arr << identifier if identifier != ""
    rescue Exception => e
      @logger.debug("no recordidentifier found with type gbv-ppn for #{@ppn}")
    end

    begin
      identifier = mods.xpath('mods:identifier[@type="ppn" or @type="PPN"]', 'mods' => 'http://www.loc.gov/mods/v3').text
      arr << identifier if identifier != ""
    rescue Exception => e
      @logger.debug("no identifier found with type ppn or PPN for #{@ppn}")
    end

    begin
      identifier = mods.xpath('mods:identifier[@type="urn" or @type="URN"]', 'mods' => 'http://www.loc.gov/mods/v3').text
      arr << identifier if identifier != ""
    rescue Exception => e
      @logger.debug("no identifier found with type urn or URN for #{@ppn}")
    end

    return arr
  end

  def enqueueInCollectionQueue(work_id, classification)
    ProcessCollection.perform_async(@ppn, work_id, classification)
  end

=begin
  def enqueueInMetsFilesetQueue(work_id)
    ProcessMetsFileSet.perform_async(@ppn, work_id)
  end

  def enqueueInBiblFilesetQueue(work_id)
    ProcessBiblFileSet.perform_async(@ppn, work_id)
  end

  def enqueueInPageFilesetQueue(work_id)
    ProcessPageFileSet.perform_async(@ppn, work_id)
  end
=end

  def enqueueInFilesetQueue(work_id)
    ProcessFileSet.perform_async(@ppn, work_id)
  end
end