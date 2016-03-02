class BibliographicFileSet < ActiveFedora::Base
  include Hydra::Works::FileSetBehavior

  property :label, predicate: ::RDF::Vocab::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end

  property :logicaltype, predicate: ::RDF::URI.new('http://opaquenamespace.org/hydra/logicalType'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :order, predicate: ::RDF::URI.new('http://opaquenamespace.org/hydra/order'), multiple: false do |index|
    index.as :stored_searchable
    index.type :integer
  end



  def page?
    false
  end

end



