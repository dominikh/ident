Gem::Specification.new do |s|
  s.name              = "ident"
  s.summary           = "A Ruby library for querying identd servers (RFC 1413)"
  s.description       = s.summary
  s.version           = "0.0.3"
  s.author            = "Dominik Honnef"
  s.email             = "dominikh@fork-bomb.org"
  s.date              = Date.today.to_s
  s.homepage          = "http://fork-bomb.org"
  s.rubyforge_project = "ident"

  s.has_rdoc = 'yard'

  s.files = Dir['Rakefile', '{bin,lib,man,test,spec,examples}/**/*',
                'README*', 'LICENSE*']
end
