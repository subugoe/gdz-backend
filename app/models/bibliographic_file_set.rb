class BibliographicFileSet < ActiveFedora::Base
  include Hydra::Works::FileSetBehavior
  property :title, predicate: ::RDF::DC.title, multiple: false
end



