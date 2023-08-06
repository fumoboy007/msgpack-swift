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

struct KeyedMessagePackDecodingContainer<Key: CodingKey> {
   private let decoder: MessagePackValueToSwiftValueDecoder

   init(decoder: MessagePackValueToSwiftValueDecoder) {
      self.decoder = decoder
   }
}

extension KeyedMessagePackDecodingContainer: KeyedDecodingContainerProtocol {
   var codingPath: [any CodingKey] {
      return decoder.codingPath
   }

   var allKeys: [Key] {
      return decoder.allKeys(of: Key.self)
   }

   func contains(_ key: Key) -> Bool {
      return decoder.contains(key)
   }

   func decodeNil(forKey key: Key) throws -> Bool {
      return try decoder.isValueNil(for: key)
   }

   func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: String.Type, forKey key: Key) throws -> String {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
      return try decoder.simpleValue(of: type, for: key)
   }

   func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
      return try decoder.compoundValue(of: type, for: key)
   }

   func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
      let nestedDecoder = try decoder.nestedDecoder(for: key)
      return KeyedDecodingContainer(try nestedDecoder.container(keyedBy: type))
   }

   func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
      let nestedDecoder = try decoder.nestedDecoder(for: key)
      return try nestedDecoder.unkeyedContainer()
   }

   func superDecoder() throws -> Decoder {
      return try decoder.nestedDecoder(for: InternalCodingKey.super)
   }

   func superDecoder(forKey key: Key) throws -> Decoder {
      return try decoder.nestedDecoder(for: key)
   }
}
