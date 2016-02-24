class BibliographicWork < ActiveFedora::Base
  include Hydra::Works::WorkBehavior
  property :title, predicate: ::RDF::DC.title, multiple: false
  property :author, predicate: ::RDF::DC.creator, multiple: false

  property :abstract, predicate: ::RDF::DC.abstract, multiple: false
end


