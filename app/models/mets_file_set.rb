class MetsFileSet < ActiveFedora::Base

  include Hydra::Works::FileSetBehavior


  property :metsVersion, predicate: ::RDF::URI.new('http://opaquenamespace.org/hydra/metsVersion'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :modsVersion, predicate: ::RDF::URI.new('http://opaquenamespace.org/hydra/modsVersion'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :recordIdentifier, predicate: ::RDF::Vocab::MODS.recordIdentifier, multiple: false do |index|
    index.as :stored_searchable
  end

  def page?
    false
  end

end



