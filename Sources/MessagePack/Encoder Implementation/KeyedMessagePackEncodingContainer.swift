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

struct KeyedMessagePackEncodingContainer<Key: CodingKey> {
   private let encoder: SwiftValueToMessagePackValueEncoder

   init(encoder: SwiftValueToMessagePackValueEncoder) {
      self.encoder = encoder
   }
}

extension KeyedMessagePackEncodingContainer: KeyedEncodingContainerProtocol {
   var codingPath: [any CodingKey] {
      return encoder.codingPath
   }

   func encodeNil(forKey key: Key) throws {
      try encoder.set(.nil, for: key)
   }

   func encode(_ value: Bool, forKey key: Key) throws {
      try encoder.set(.boolean(value), for: key)
   }

   func encode(_ value: String, forKey key: Key) throws {
      try encoder.set(.string(value.utf8), for: key)
   }

   func encode(_ value: Double, forKey key: Key) throws {
      try encoder.set(.float64(value), for: key)
   }

   func encode(_ value: Float, forKey key: Key) throws {
      try encoder.set(.float32(value), for: key)
   }

   func encode(_ value: Int, forKey key: Key) throws {
      try encoder.set(.init(value), for: key)
   }

   func encode(_ value: Int8, forKey key: Key) throws {
      try encoder.set(.init(value), for: key)
   }

   func encode(_ value: Int16, forKey key: Key) throws {
      try encoder.set(.init(value), for: key)
   }

   func encode(_ value: Int32, forKey key: Key) throws {
      try encoder.set(.init(value), for: key)
   }

   func encode(_ value: Int64, forKey key: Key) throws {
      try encoder.set(.init(value), for: key)
   }

   func encode(_ value: UInt, forKey key: Key) throws {
      try encoder.set(.init(value), for: key)
   }

   func encode(_ value: UInt8, forKey key: Key) throws {
      try encoder.set(.init(value), for: key)
   }

   func encode(_ value: UInt16, forKey key: Key) throws {
      try encoder.set(.init(value), for: key)
   }

   func encode(_ value: UInt32, forKey key: Key) throws {
      try encoder.set(.init(value), for: key)
   }

   func encode(_ value: UInt64, forKey key: Key) throws {
      try encoder.set(.init(value), for: key)
   }

   func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
      if let messagePackValue = EncodableMessagePackValue(standardCompoundValue: value) {
         try encoder.set(messagePackValue, for: key)
      } else {
         let nestedEncoder = encoder.nestedEncoder(for: key)
         try value.encode(to: nestedEncoder)
      }
   }

   func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
      let nestedEncoder = encoder.nestedEncoder(for: key)
      return KeyedEncodingContainer(nestedEncoder.container(keyedBy: keyType))
   }

   func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
      let nestedEncoder = encoder.nestedEncoder(for: key)
      return nestedEncoder.unkeyedContainer()
   }

   func superEncoder() -> Encoder {
      return encoder.nestedEncoder(for: InternalCodingKey.super)
   }

   func superEncoder(forKey key: Key) -> Encoder {
      return encoder.nestedEncoder(for: key)
   }
}
