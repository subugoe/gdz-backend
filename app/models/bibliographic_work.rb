class BibliographicWork < ActiveFedora::Base
  include Hydra::Works::WorkBehavior

  filters_association :members, as: :pages, condition: :page?

  property :title, predicate: ::RDF::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end


  property :author, predicate: ::RDF::DC.creator, multiple: false do |index|
    index.as :stored_searchable
  end

  property :abstract, predicate: ::RDF::DC.abstract, multiple: false do |index|
    index.as :stored_searchable
  end

  def page?
    false
  end
  
end


