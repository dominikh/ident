require 'rake/gempackagetask'

VERSION = "0.0.3"

spec = Gem::Specification.new do |s|
  s.name              = "ident"
  s.summary           = "A Ruby library for querying identd servers (RFC 1413)"
  s.description       = s.summary
  s.version           = VERSION
  s.author            = "Dominik Honnef"
  s.email             = "dominikh@fork-bomb.org"
  s.date              = Time.now.strftime "%Y-%m-%d"
  s.require_path      = "lib"
  s.homepage          = "http://fork-bomb.org"
  s.platform          = Gem::Platform::RUBY
  s.rubyforge_project = "ident"

  s.has_rdoc = 'yard'

  s.files = FileList["lib/**/*.rb", "[A-Z]*", "examples/**/*"].to_a
end

Rake::GemPackageTask.new(spec)do |pkg|
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
  end
rescue LoadError
end

task :test do
  begin
    require "baretest"
  rescue LoadError => e
    puts "Could not run tests: #{e}"
  end

  BareTest.load_standard_test_files(
                                    :verbose => false,
                                    :setup_file => 'test/setup.rb',
                                    :chdir => File.absolute_path("#{__FILE__}/../")
                                    )

  BareTest.run(:format => "cli", :interactive => false)
end
