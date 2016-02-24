class BibliographicFileSet < ActiveFedora::Base
  include Hydra::Works::FileSetBehavior
  property :title, predicate: ::RDF::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end

  def page?
    false
  end

end



