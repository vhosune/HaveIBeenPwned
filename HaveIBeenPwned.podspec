Pod::Spec.new do |spec|

    spec.name        = "HaveIBeenPwned"
    spec.version     = "2.0.0"
    spec.summary     = "Swift library for haveibeenpwned.com (v3)"
    spec.homepage    = "https://github.com/vhosune/HaveIBeenPwned"
    spec.license     = { :type => "MIT", :file => "LICENSE" }
    spec.author      = { "Vincent HO-SUNE" => "vhosune@gmail.com" }

    spec.swift_version = '5.1'

    spec.ios.deployment_target     = "8.0"
    spec.osx.deployment_target     = "10.10"
    spec.watchos.deployment_target = "2.0"
    spec.tvos.deployment_target    = "9.0"

    spec.source = {
        :git => "https://github.com/vhosune/HaveIBeenPwned.git",
        :tag => "#{spec.version}"
    }

    spec.source_files  = "HaveIBeenPwned/**/*.{swift}"

end
