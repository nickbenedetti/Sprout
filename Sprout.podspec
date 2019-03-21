Pod::Spec.new do |s|
  s.name                = "Sprout"
  s.version             = "3.1.1"
  s.summary             = "Bootstrap the CocoaLumberjack logging framework."
  s.description         = <<-DESC
		Bootstrap the CocoaLumberjack logging framework and add additional functionality such as Custom Loggers, log archiving, crash stack traces, and more.
    DESC
  s.homepage            = "https://github.com/levigroker/Sprout"
  s.license             = 'Creative Commons Attribution 4.0 International License'
  s.author              = { "Levi Brown" => "levigroker@gmail.com" }
  s.social_media_url    = 'https://twitter.com/levigroker'
  s.source              = { :git => "https://github.com/levigroker/Sprout.git", :tag => s.version.to_s }
  s.requires_arc        = true
  s.source_files        = 'Sprout/*.{h,m}'
  s.public_header_files = 'Sprout/*.h'
  s.frameworks          = 'Foundation'
  s.dependency 'CocoaLumberjack', '~> 3.5'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'

end
