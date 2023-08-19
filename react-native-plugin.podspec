# @speedchecker/react-native-plugin.podspec

require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-plugin"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package['homepage']
  s.license      = package['license']
  s.authors      = package['author']
  s.platforms    = { :ios => "11.0" }
  s.ios.deployment_target = '11.0'

  s.source       = { :git => package['repository']['url'], :tag => "#{s.version}" }
  s.source_files = "ios/**/*.{h,c,cc,cpp,m,mm,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency 'SpeedcheckerSDK', '1.5.66'
end

