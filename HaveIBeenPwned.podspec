
Pod::Spec.new do |s|

  s.name         = "HaveIBeenPwned"
  s.version      = "1.0.1"
  s.summary      = "Swift library for haveibeenpwned.com"
  s.description  = <<-DESC
Swift Library to haveibeenpwned.com API based on API v2.
- You can check if a password has already been pwned in a breach.
- You can query for known breaches
DESC

  s.homepage     = "https://github.com/vhosune/HaveIBeenPwned"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Vincent HO-SUNE" => "vhosune@gmail.com" }
  s.source       = { :git => "https://github.com/vhosune/HaveIBeenPwned.git", :tag => s.version.to_s }
  s.ios.source_files  = "HaveIBeenPwned/**/*.{h,swift}"
  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'

end
