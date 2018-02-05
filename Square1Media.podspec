Pod::Spec.new do |s|

  s.name         = "Square1Media"
  s.version      = "1.0.1"
  s.summary      = "A group of types and helpers to deal with media (audio, images...)"
  s.description  = "A handy collection of types, helpers and extensions to make our lifes easier when dealing with multimedia."
  s.homepage     = "https://github.com/square1-io/Square1-iOS-Media"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = "Square1"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/square1-io/Square1-iOS-Media.git", :tag => s.version }
  s.source_files  = "Source", "Source/**/*.swift"
  s.dependency 'Square1Network'
end
