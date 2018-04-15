#
# Be sure to run `pod lib lint UInt128.podspec' to ensure this is a
# valid spec before submitting.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  # Project metadata
  spec.name = 'UInt128'
  spec.version = '0.8.0'
  spec.summary = 'A Swift 128-bit Unsigned Integer Data Type'
  spec.description = <<~DESC
     This library provides a Swift 4.0 compatible 128-bit Unsigned Integer
     data type. It includes support for all of the protocols that you would
     expect from a native UnsignedInteger type in the Swift standard library.
  DESC
  spec.homepage = 'https://github.com/Jitsusama/UInt128'
  spec.license = {
    :type => 'Apache-2.0',
    :file => 'LICENSE'
  }
  spec.author = {
    'Joel Gerber' => 'joel@grrbrr.ca'
  }
  spec.source = {
    :git => 'https://github.com/Jitsusama/UInt128.git',
    :tag => spec.version.to_s
  }

  # Where to look for source files
  spec.source_files = 'Sources/*'

  # State supported version of the Swift library
  spec.swift_version = "4.0"

  # OS deployment targets
  spec.ios.deployment_target = "8.0"
  spec.tvos.deployment_target = "9.0"
  spec.osx.deployment_target = "10.9"
  spec.watchos.deployment_target = "2.0"
end
