#
# Be sure to run `pod lib lint UInt128.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UInt128'
  s.version          = '0.7.0'
  s.summary          = 'A Swift 128-bit Unsigned Integer Data Type conforming to the UnsignedInteger Protocol'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                       A Swift 128-bit Unsigned Integer Data Type conforming to the UnsignedInteger Protocol. 
                       This library also implements a number of other initializers and properties that Swift's native unsigned integer types support.
                       DESC

  s.homepage         = 'https://github.com/Jitsusama/UInt128'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Jitsusama' => 'i@gmail.com' }
  s.source           = { :git => 'https://github.com/Jitsusama/UInt128.git', :tag => s.version.to_s }
  s.swift_version = "4.0"

  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"

  s.source_files = 'Sources/*'
  
end
