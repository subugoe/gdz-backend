class BibliographicWork < ActiveFedora::Base
  include Hydra::Works::WorkBehavior

  filters_association :members, as: :pages, condition: :page?

  before_destroy :destroy_from_related_object

  property :title, predicate: ::RDF::Vocab::MODS.title, multiple: false do |index|
    index.as :stored_searchable
  end

  property :creator, predicate: ::RDF::Vocab::DC.creator, multiple: false do |index|
    index.as :stored_searchable
  end

  property :abstract, predicate: ::RDF::Vocab::DC.abstract, multiple: false do |index|
    index.as :stored_searchable
  end

  #
  property :recordIdentifier, predicate: ::RDF::Vocab::MODS.recordIdentifier, multiple: false do |index|
    index.as :stored_searchable
  end

  property :identifiers, predicate: ::RDF::Vocab::MODS.identifier, multiple: true do |index|
    index.as :stored_searchable
  end

  property :purl, predicate: ::RDF::URI.new('http://opaquenamespace.org/hydra/purl'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :classifications, predicate: ::RDF::Vocab::MODS.classification, multiple: true do |index|
    index.as :stored_searchable
  end


  property :placeOfOrigin, predicate: ::RDF::Vocab::MODS.placeOfOrigin, multiple: false do |index|
    index.as :stored_searchable
  end


  property :dateCreated, predicate: ::RDF::Vocab::MODS.dateCreated, multiple: false do |index|
    index.as :stored_searchable
    index.type :integer
  end

  property :publisher, predicate: ::RDF::Vocab::DC.publisher, multiple: false do |index|
    index.as :stored_searchable
  end

  # todo which vocab to use for structtypes?
  property :structype, predicate: ::RDF::Vocab::DC.type, multiple: false do |index|
    index.as :stored_searchable
  end


  # todo which vocab to use for physicalDescription?
  property :physicalDescription, predicate: ::RDF::Vocab::DC.extent, multiple: false do |index|
    index.as :stored_searchable
  end

  # languageTerm
  property :languageTerm, predicate: ::RDF::Vocab::DC.language, multiple: false do |index|
    index.as :stored_searchable
  end

  # todo destroy from related object
  def destroy_from_related_object

  end

  def page?
    false
  end

end


