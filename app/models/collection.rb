class Collection < ActiveFedora::Base
  include Hydra::Works::CollectionBehavior

  property :title, predicate: ::RDF::Vocab::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end

  property :recordIdentifier, predicate: ::RDF::Vocab::MODS.recordIdentifier, multiple: false do |index|
    index.as :stored_searchable
  end

end

