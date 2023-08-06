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

struct SingleValueMessagePackEncodingContainer {
   private let encoder: SwiftValueToMessagePackValueEncoder

   init(encoder: SwiftValueToMessagePackValueEncoder) {
      self.encoder = encoder
   }
}

extension SingleValueMessagePackEncodingContainer: SingleValueEncodingContainer {
   var codingPath: [any CodingKey] {
      return encoder.codingPath
   }

   func encodeNil() throws {
      encoder.store(.nil)
   }

   func encode(_ value: Bool) throws {
      encoder.store(.boolean(value))
   }

   func encode(_ value: String) throws {
      encoder.store(.string(value.utf8))
   }

   func encode(_ value: Double) throws {
      encoder.store(.float64(value))
   }

   func encode(_ value: Float) throws {
      encoder.store(.float32(value))
   }

   func encode(_ value: Int) throws {
      encoder.store(.init(value))
   }

   func encode(_ value: Int8) throws {
      encoder.store(.init(value))
   }

   func encode(_ value: Int16) throws {
      encoder.store(.init(value))
   }

   func encode(_ value: Int32) throws {
      encoder.store(.init(value))
   }

   func encode(_ value: Int64) throws {
      encoder.store(.init(value))
   }

   func encode(_ value: UInt) throws {
      encoder.store(.init(value))
   }

   func encode(_ value: UInt8) throws {
      encoder.store(.init(value))
   }

   func encode(_ value: UInt16) throws {
      encoder.store(.init(value))
   }

   func encode(_ value: UInt32) throws {
      encoder.store(.init(value))
   }

   func encode(_ value: UInt64) throws {
      encoder.store(.init(value))
   }

   func encode<T: Encodable>(_ value: T) throws {
      if let messagePackValue = EncodableMessagePackValue(standardCompoundValue: value) {
         encoder.store(messagePackValue)
      } else {
         let nestedEncoder = encoder.nestedEncoder()
         try value.encode(to: nestedEncoder)
      }
   }
}
