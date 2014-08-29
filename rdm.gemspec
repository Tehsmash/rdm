Gem::Specification.new do |s|
  s.name        = 'rdm'
  s.version     = '0.1.0'
  s.date        = '2014-08-29'
  s.summary     = "Ruby Display Manager"
  s.description = "A Ruby, GTK and Webkit powered display manager for linux."
  s.authors     = ["Sam Betts"]
  s.email       = 'sam@code-smash.net'
  s.files       = ["lib/rdm.rb", "lib/rdm/panel.rb", "lib/rdm/xserver.rb", "lib/rdm/config.rb"]
  s.executables << 'rdm'
  s.homepage    =
        'http://www.code-smash.net/rdm'
  s.license       = 'Apache v2'
end
