require 'nokogiri'
require 'open-uri'
require 'benchmark'
require 'redis-semaphore'


class ProcessCollectionHelper


  def initialize(ppn, work_id, colname)
    @s = Redis::Semaphore.new(:collection_semaphore, :host => "redis")

    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG

    @ppn     = ppn
    @work_id = work_id
    @colname = colname
  end

  def createCollection

    # todo remove the lock if possible

    colnameWithoutWithespaces = @colname.gsub(/\s/, '_')
    col = nil

    @s.lock do
      begin
        col = Collection.where(recordIdentifier: colnameWithoutWithespaces).first
        if col == nil
          col = Collection.create() do |c|
            c.title = @colname
            c.recordIdentifier = colnameWithoutWithespaces
          end
        end
      rescue ActiveFedora::ObjectNotFoundError => e # ActiveFedora::ObjectNotFoundError
        col = Collection.create() do |c|
          c.title = @colname
          c.recordIdentifier = colnameWithoutWithespaces
        end

        @logger.debug("new collection #{@colname} created")
      rescue Exception => e
        @logger.debug("Exception (#{e.message}) while find or create collection '#{colnameWithoutWithespaces}'")
      end

    end

    addToMembers(col)

  end

  def addToMembers(collection)

    begin
      bw = BibliographicWork.find(@work_id)

      contained = collection.members.select { |m| m.id == bw.id }

      if contained.empty?
        collection.members << bw
        @s.lock do
          collection.save
        end
      end

    rescue ActiveFedora::ObjectNotFoundError
      @logger.debug("BibliographicWork '#{@work_id}' could not be found, it is not added to collection #{collection.title}")
    rescue Exception => e
      @logger.debug("Exception (#{e.message}) while add work '#{@work_id}' as member to collection '#{collection.title}'")
      e.backtrace.each {|bt| puts "--> #{bt}"}
    end

  end

end