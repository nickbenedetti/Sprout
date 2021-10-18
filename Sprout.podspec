Pod::Spec.new do |s|
  s.name                = "Sprout"
  s.version             = "3.2.3"
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
  s.dependency 'CocoaLumberjack', '~> 3.7'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.watchos.deployment_target = '7.0'
end
