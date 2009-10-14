require 'rake/gempackagetask'
require 'yard'

VERSION = "0.0.1"

spec = Gem::Specification.new do |s|
  s.name              = "ident"
  s.summary           = "A Ruby library for querying identd servers (RFC 1413)"
  s.description       = s.summary
  s.version           = VERSION
  s.author            = "Dominik Honnef"
  s.email             = "dominikho@gmx.net"
  s.date              = Time.now.strftime "%Y-%m-%d"
  s.require_path      = "lib"
  s.homepage          = "http://dominikh.fork-bomb.de"
  s.platform          = Gem::Platform::RUBY
  s.rubyforge_project = "ident"

  s.files = FileList["lib/**/*.rb", "[A-Z]*", "doc/**/*", "examples/**/*"].to_a
end

Rake::GemPackageTask.new(spec)do |pkg|
end

YARD::Rake::YardocTask.new do |t|
end

