
Pod::Spec.new do |spec|
  spec.name         = "FeatureToggleKit"
  spec.version      = "0.0.0"
  spec.module_name  = spec.name.to_s
  spec.summary      = spec.name.to_s
  spec.description  = <<-DESC
                       TBD
                       DESC
  spec.homepage     = "git@github.com:harryngict/FeatureToggleKit.git"
  spec.source      = {
   :git => spec.homepage.to_s,
   :tag => spec.name.to_s + '-' + spec.version.to_s
  }
  spec.authors      = { "Harry - Nguyen Chi Hoang" => "harryngict@gmail.com" }
  spec.license      = { :type => "MIT", :text => "Copyright © 2025" }
  spec.requires_arc = true
  spec.static_framework = false
  spec.platform   = :ios, "15.0"
  spec.swift_version = '6.0'
  spec.cocoapods_version    = '>= 1.12.0'
  spec.source_files = "Sources/FeatureToggleKit/interfaces/src/**/*.{swift}"
end
