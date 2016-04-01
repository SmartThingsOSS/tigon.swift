Pod::Spec.new do |spec|
  spec.name = "Tigon"
  spec.version = "1.0.0"
  spec.summary = "A Comunication layer between iOS and Javascript"
  spec.homepage = "https://github.com/SmartThingsOSS/tigon-ios"
  spec.license = { type: 'Apache License, Version 2.0', file: 'LICENSE' }
  spec.authors = { "Steve Vlaminck" => 'steve@smartthings.com' }
  spec.social_media_url = "https://twitter.com/bearduino"
  spec.platform = :ios, "8.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/SmartThingsOSS/tigon.swift.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "Tigon/**/*.{h,swift}"
end
