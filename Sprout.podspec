Pod::Spec.new do |s|
  s.name             = "Sprout"
  s.version          = "2.2"
  s.summary          = "Bootstrap the CocoaLumberjack logging framework."
  s.description      = <<-DESC
		Bootstrap the CocoaLumberjack logging framework and add additional functionality such as Custom Loggers, log archiving, crash stack traces, and more.
    DESC
  s.homepage         = "https://github.com/levigroker/Sprout"
  s.license          = 'Creative Commons Attribution 3.0 Unported License'
  s.author           = { "Levi Brown" => "levigroker@gmail.com" }
  s.social_media_url = 'https://twitter.com/levigroker'
  s.source           = { :git => "https://github.com/levigroker/Sprout.git", :tag => s.version.to_s }
  s.source_files     = 'Sprout/**/*.{h,m}'
  s.frameworks       = 'Foundation'
  s.requires_arc     = true
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.9'
  s.dependency 'CocoaLumberjack', '~> 1.9'
end
