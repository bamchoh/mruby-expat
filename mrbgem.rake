MRuby::Gem::Specification.new('mruby-expat') do |spec|
  spec.license = 'MIT'
  spec.authors = 'bamchoh'

  flags = '-I/root/git/expat-code_git/expat -I/root/git/expat-code_git/expat/lib'
  libraries = "expat"

  spec.cc.flags << flags

  spec.linker.flags << flags
  spec.linker.library_paths << '-L/root/git/expat-code_git/expat/.libs'
  spec.linker.libraries << libraries
end
