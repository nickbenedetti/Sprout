Pod::Spec.new do |s|
  s.name             = "Sprout"
  s.version          = "3.0"
  s.summary          = "Bootstrap the CocoaLumberjack logging framework."
  s.description      = <<-DESC
		Bootstrap the CocoaLumberjack logging framework and add additional functionality such as Custom Loggers, log archiving, crash stack traces, and more.
    DESC
  s.homepage         = "https://github.com/levigroker/Sprout"
  s.license          = 'Creative Commons Attribution 4.0 International License'
  s.author           = { "Levi Brown" => "levigroker@gmail.com" }
  s.social_media_url = 'https://twitter.com/levigroker'
  s.source           = { :git => "https://github.com/levigroker/Sprout.git", :tag => s.version.to_s }
  s.source_files     = 'Sprout/**/*.{h,m}'
  s.frameworks       = 'Foundation'
  s.requires_arc     = true
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.dependency 'CocoaLumberjack', '~> 3.0'
end
