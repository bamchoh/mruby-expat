MRuby::Gem::Specification.new('mruby-expat') do |spec|
  spec.license = 'MIT'
  spec.authors = 'bamchoh'
  spec.linker.libraries << "expat"
end
