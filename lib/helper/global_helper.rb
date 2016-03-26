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
    File.delete(mets_path(@ppn))
  end

  def findBibliographicWork
    begin
      return BibliographicWork.find(@work_id)
    rescue ActiveFedora::ObjectNotFoundError => e
      @logger.debug(" BibliographicWork #{@work_id} not Found")
    end
    return nil
  end

  def addToMembers(container, element)
    contained = container.members.select { |m| m.id == element.id }

    if contained.empty?
      container.members << element
      container.save
    end
  end


end