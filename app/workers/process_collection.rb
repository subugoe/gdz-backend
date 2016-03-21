class ProcessCollection
  include Sidekiq::Worker

  sidekiq_options queue: :collection, backtrace: true

  def initialize
    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end

  def perform(ppn, work_id, classification)
    col               = createCollection(classification)
    addToMembers(col, work_id)
    @logger.info("process #{ppn}")
  end

  def createCollection(colname)

    begin
      col = Collection.find(colname)
    rescue # ActiveFedora::ObjectNotFoundError
      # if (col == nil)
      col       = Collection.new(colname)
      col.title = colname
      col.save
      # end
    end

    return col

  end

  def addToMembers(collection, work_id)

    bw = BibliographicWork.find(work_id)

    contained = collection.members.select { |m| m.id == bw.id }

    if contained.empty?
      collection.members << bw
      collection.save
    end
  end

end