class PageFileSet < ActiveFedora::Base
  include Hydra::Works::FileSetBehavior

  property :order, predicate: ::RDF::URI.new('http://opaquenamespace.org/hydra/pageNumber'), multiple: false do |index|
    index.as :stored_searchable
    index.type :integer
  end

  property :orderlabel, predicate: ::RDF::URI.new('http://opaquenamespace.org/hydra/pageLabel'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :pagetype, predicate: ::RDF::URI.new('http://opaquenamespace.org/hydra/pageType'), multiple: false do |index|
    index.as :stored_searchable
  end


  def page?
    true
  end

end



