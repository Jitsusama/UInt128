# UInt128
A Swift 128-bit Unsigned Integer Data Type conforming to the UnsignedInteger Protocol.
This library also implements a number of other initializers and properties that Swift's
native unsigned integer types support.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Installation
This library includes Carthage and SPM support out of the box. Reference this git
repository in a Cartfile or Package.swift file in order to easily include this library
while also being able to easily track changes.

You can also manually copy over the Sources/UInt128.swift file into your project and
it should work great. I've purposely kept this library constrained to a single file in
order to support this use case.

## Usage
Since this library fully implements the UnsignedInteger protocol, you can use this data
type just like any other native UInt data type. For numbers larger than UIntMax, you'll
either want to call the `init(upperBits: UInt64, lowerBits: UInt64)` initializer, or,
use the `init(stringLiteral: String)` initializer to create an instance with a string.
The string can be in binary, octal, decimal or hexadecimal.

For example:

    let uInt128ByString: UInt128 = "0xffaabbcc00129823fa9a12d4aa87f498"
    let uInt128ByInteger: UInt128 = 1234

## Building
This project includes an example Xcode project for building the framework that also includes
a playground that can be utilized for testing things out. This Xcode project can build from
one target a iphone, iphonesimulator or mac os x build. It also includes unit testing and
code coverage.
