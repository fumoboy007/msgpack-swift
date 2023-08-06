// MIT License
//
// Copyright © 2023 Darren Mo.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

struct SingleValueMessagePackDecodingContainer {
   private let decoder: MessagePackValueToSwiftValueDecoder

   init(decoder: MessagePackValueToSwiftValueDecoder) {
      self.decoder = decoder
   }
}

extension SingleValueMessagePackDecodingContainer: SingleValueDecodingContainer {
   var codingPath: [any CodingKey] {
      return decoder.codingPath
   }

   func decodeNil() -> Bool {
      return decoder.isValueNil()
   }

   func decode(_ type: Bool.Type) throws -> Bool {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: String.Type) throws -> String {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: Double.Type) throws -> Double {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: Float.Type) throws -> Float {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: Int.Type) throws -> Int {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: Int8.Type) throws -> Int8 {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: Int16.Type) throws -> Int16 {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: Int32.Type) throws -> Int32 {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: Int64.Type) throws -> Int64 {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: UInt.Type) throws -> UInt {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: UInt8.Type) throws -> UInt8 {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: UInt16.Type) throws -> UInt16 {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: UInt32.Type) throws -> UInt32 {
      return try decoder.simpleValue(of: type)
   }

   func decode(_ type: UInt64.Type) throws -> UInt64 {
      return try decoder.simpleValue(of: type)
   }

   func decode<T: Decodable>(_ type: T.Type) throws -> T {
      return try decoder.compoundValue(of: type)
   }
}
