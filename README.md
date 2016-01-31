# UInt128
A Swift 128-bit Unsigned Integer Data Type conforming to the UnsignedInteger Protocol

## Usage
Since this library fully implements the UnsignedInteger protocol, you can use this data
type just like any other native UInt data type. For numbers larger than UIntMax, you'll
either want to call the `init(upperBits: UInt64, lowerBits: UInt64)` initializer, or,
use the `init(stringLiteral: String)` initializer to create an instance with a string.
The string can be in binary, octal, decimal or hexadecimal.

## Example
let uInt128ByString: UInt128 = "0xffaabbcc00129823fa9a12d4aa87f498"
let uInt128ByInteger: UInt128 = 1234
