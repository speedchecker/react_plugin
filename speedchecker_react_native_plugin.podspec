require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = s.name = "speedchecker_react_native_plugin"
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']
  s.authors      = package['author']
  s.homepage     = package['repository']['url']
  s.platform     = :ios, "11.0"
  s.ios.deployment_target = '11.0'

  s.source       = { :git => package['repository']['url'], :tag => "#{s.version}" }
  s.source_files  = "ios/**/*.{h,m,swift}"

  s.dependency 'SpeedcheckerSDK', '1.5.66'
end