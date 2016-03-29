module GlobalHelper

  def metsUri
    return "http://gdz.sub.uni-goettingen.de/mets/#{@ppn}.xml"
  end

  def metsPath
    return "tmp_data/#{@ppn}.xml"
  end

  def work_id
    "#{@ppn}_work"
  end

  def createFile()
    File.write(metsPath(), @doc.to_xml)
  end

  def fileDelete
    File.delete(mets_path())
  end

  def openDocFromPath
    begin
      return Nokogiri::XML(File.open(metsPath()))
    rescue Exception => e
      @logger.debug("problems to open file #{metsPath()} for #{@ppn}")
      return
    end
  end

  def openDocFromUri
    begin
      return Nokogiri::XML(open(metsUri()))
    rescue Exception => e
      @logger.debug("problems to open file #{metsUri()} for #{@ppn}")
      return
    end
  end

  def findBibliographicWork
    begin
      return BibliographicWork.where(recordIdentifier: @work_id).first
    rescue ActiveFedora::ObjectNotFoundError => e
      @logger.debug(" BibliographicWork #{@work_id} not Found")
    end
    return nil
  end

  def addMemberToContainer(container, element)
    contained = container.members.select { |m| m.id == element.id }

    if contained.empty?
      container.members << element
      @s.lock do
        container.save
      end
    end
  end

  def addMemberToWork(member)
    begin
      work = BibliographicWork.find(@work_id)
      addMemberToContainer(work, member)  if work != nil
    rescue ActiveFedora::ObjectNotFoundError => e
      @logger.debug("BibliographicWork #{@work_id} not found, member #{member.id} could not be associated")
    rescue Exception => e
      @logger.debug("Exception (#{e.message}) while find BibliographicWork '#{@work_id}'")
    end
  end

  def addMemberToBibliographicWork(pfs, order)
    bfs_if = "#{@ppn}_logical_#{order}"
    begin
      bfs = BibliographicFileSet.where(recordIdentifier: bfs_if).first
      addMemberToContainer(bfs, pfs)  if bfs != nil
    rescue ActiveFedora::ObjectNotFoundError => e
      @logger.debug("BibliographicFileSet #{bfs_if} not found, member #{pfs.id} could not be associated")
    rescue Exception => e
      @logger.debug("Exception (#{e.message}) while find BibliographicFileSet '#{bfs_if}'")
    end

  end


end