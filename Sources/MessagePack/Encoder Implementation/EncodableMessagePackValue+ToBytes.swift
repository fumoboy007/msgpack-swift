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

import Foundation

extension EncodableMessagePackValue {
   func encode(to messageWriter: inout MessageWriter) throws {
      switch self {
      case .future(let future):
         let value = try future.encodableMessagePackValue
         try value.encode(to: &messageWriter)

      case .nil:
         encodeNil(to: &messageWriter)

      case .boolean(let value):
         encode(value, to: &messageWriter)

      case .signedInteger(let value):
         encode(value, to: &messageWriter)

      case .unsignedInteger(let value):
         encode(value, to: &messageWriter)

      case .float32(let value):
         encode(value, to: &messageWriter)

      case .float64(let value):
         encode(value, to: &messageWriter)

      case .string(let value):
         encode(value, to: &messageWriter)

      case .binary(let value):
         encode(value, to: &messageWriter)

      case .array(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            try value.encode(to: &messageWriter)
         }

      case .map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            try EncodableMessagePackValue(key).encode(to: &messageWriter)
            try value.encode(to: &messageWriter)
         }

      case .applicationSpecificExtension(let value):
         encode(value, to: &messageWriter)

      case .messagePackTimestamp(let value):
         encode(value, to: &messageWriter)

      case .boolArray(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .intArray(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .int8Array(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .int16Array(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .int32Array(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .int64Array(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .uintArray(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .uint8Array(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .uint16Array(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .uint32Array(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .uint64Array(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .float32Array(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .float64Array(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .cgFloatArray(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .stringArray(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value.utf8, to: &messageWriter)
         }

      case .dataArray(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .timestampArray(let array):
         encodeCount(of: array, to: &messageWriter)

         for value in array {
            encode(value, to: &messageWriter)
         }

      case .boolSet(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .intSet(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .int8Set(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .int16Set(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .int32Set(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .int64Set(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .uintSet(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .uint8Set(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .uint16Set(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .uint32Set(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .uint64Set(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .float32Set(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .float64Set(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .cgFloatSet(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .stringSet(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value.utf8, to: &messageWriter)
         }

      case .dataSet(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .timestampSet(let set):
         encodeCount(of: set, to: &messageWriter)

         for value in set {
            encode(value, to: &messageWriter)
         }

      case .stringToBoolMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToIntMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToInt8Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToInt16Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToInt32Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToInt64Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToUIntMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToUInt8Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToUInt16Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToUInt32Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToUInt64Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToFloat32Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToFloat64Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToCGFloatMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToStringMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value.utf8, to: &messageWriter)
         }

      case .stringToDataMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .stringToTimestampMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(key.utf8, to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToBoolMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToIntMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToInt8Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToInt16Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToInt32Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToInt64Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToUIntMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToUInt8Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToUInt16Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToUInt32Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToUInt64Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToFloat32Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToFloat64Map(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToCGFloatMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToStringMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value.utf8, to: &messageWriter)
         }

      case .intToDataMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }

      case .intToTimestampMap(let dictionary):
         encodeCount(of: dictionary, to: &messageWriter)

         for (key, value) in dictionary {
            encode(Int64(key), to: &messageWriter)
            encode(value, to: &messageWriter)
         }
      }
   }

   private func encodeNil(to messageWriter: inout MessageWriter) {
      messageWriter.write(byte: 0xc0)
   }

   private func encode(_ value: Bool, to messageWriter: inout MessageWriter) {
      messageWriter.write(byte: value ? 0xc3 : 0xc2)
   }

   private func encode<T>(_ value: T, to messageWriter: inout MessageWriter) where T: SignedInteger & FixedWidthInteger {
      if let value = Int8(exactly: value) {
         switch value {
         case 0...127:
            encodeAsPositiveFixint(value, to: &messageWriter)

         case -32..<0:
            encodeAsNegativeFixint(value, to: &messageWriter)

         default:
            messageWriter.write(byte: 0xd0)
            messageWriter.write(byte: UInt8(bitPattern: value))
         }
      } else if let value = Int16(exactly: value) {
         messageWriter.write(byte: 0xd1)
         withUnsafeBytes(of: value.bigEndian) {
            messageWriter.write($0)
         }
      } else if let value = Int32(exactly: value) {
         messageWriter.write(byte: 0xd2)
         withUnsafeBytes(of: value.bigEndian) {
            messageWriter.write($0)
         }
      } else {
         messageWriter.write(byte: 0xd3)
         withUnsafeBytes(of: value.bigEndian) {
            messageWriter.write($0)
         }
      }
   }

   private func encode<T>(_ value: T, to messageWriter: inout MessageWriter) where T: UnsignedInteger & FixedWidthInteger {
      if let value = UInt8(exactly: value) {
         switch value {
         case 0...127:
            encodeAsPositiveFixint(value, to: &messageWriter)

         default:
            messageWriter.write(byte: 0xcc)
            messageWriter.write(byte: value)
         }
      } else if let value = UInt16(exactly: value) {
         messageWriter.write(byte: 0xcd)
         withUnsafeBytes(of: value.bigEndian) {
            messageWriter.write($0)
         }
      } else if let value = UInt32(exactly: value) {
         messageWriter.write(byte: 0xce)
         withUnsafeBytes(of: value.bigEndian) {
            messageWriter.write($0)
         }
      } else {
         messageWriter.write(byte: 0xcf)
         withUnsafeBytes(of: value.bigEndian) {
            messageWriter.write($0)
         }
      }
   }

   private func encodeAsPositiveFixint<T: BinaryInteger>(_ value: T, to messageWriter: inout MessageWriter) {
      messageWriter.write(byte: UInt8(value))
   }

   private func encodeAsNegativeFixint<T: SignedInteger>(_ value: T, to messageWriter: inout MessageWriter) {
      messageWriter.write(byte: UInt8(bitPattern: Int8(value)))
   }

   private func encode(_ value: Float32, to messageWriter: inout MessageWriter) {
      messageWriter.write(byte: 0xca)
      withUnsafeBytes(of: value.bitPattern.bigEndian) {
         messageWriter.write($0)
      }
   }

   private func encode(_ value: Float64, to messageWriter: inout MessageWriter) {
      if let value = Float32(exactly: value) {
         encode(value, to: &messageWriter)
         return
      }

      messageWriter.write(byte: 0xcb)
      withUnsafeBytes(of: value.bitPattern.bigEndian) {
         messageWriter.write($0)
      }
   }

   private func encode(_ utf8: String.UTF8View, to messageWriter: inout MessageWriter) {
      let byteCount = utf8.count
      if let byteCount = UInt8(exactly: byteCount) {
         switch byteCount {
         case 0..<(1<<5):
            messageWriter.write(byte: 0b10100000 | byteCount)

         default:
            messageWriter.write(byte: 0xd9)
            messageWriter.write(byte: byteCount)
         }
      } else if let byteCount = UInt16(exactly: byteCount) {
         messageWriter.write(byte: 0xda)
         withUnsafeBytes(of: byteCount.bigEndian) {
            messageWriter.write($0)
         }
      } else if let byteCount = UInt32(exactly: byteCount) {
         messageWriter.write(byte: 0xdb)
         withUnsafeBytes(of: byteCount.bigEndian) {
            messageWriter.write($0)
         }
      } else {
         preconditionFailure("Unsupported UTF-8 byte count \(byteCount) should have been blocked earlier in the encoding flow.")
      }

      let isContiguousStorageAvailable = utf8.withContiguousStorageIfAvailable {
         messageWriter.write(UnsafeRawBufferPointer($0))
         return true
      } ?? false
      if isContiguousStorageAvailable {
         return
      }

      for byte in utf8 {
         messageWriter.write(byte: byte)
      }
   }

   private func encode(_ data: Data, to messageWriter: inout MessageWriter) {
      let byteCount = data.count
      if let byteCount = UInt8(exactly: byteCount) {
         messageWriter.write(byte: 0xc4)
         messageWriter.write(byte: byteCount)
      } else if let byteCount = UInt16(exactly: byteCount) {
         messageWriter.write(byte: 0xc5)
         withUnsafeBytes(of: byteCount.bigEndian) {
            messageWriter.write($0)
         }
      } else if let byteCount = UInt32(exactly: byteCount) {
         messageWriter.write(byte: 0xc6)
         withUnsafeBytes(of: byteCount.bigEndian) {
            messageWriter.write($0)
         }
      } else {
         preconditionFailure("Unsupported data byte count \(byteCount) should have been blocked earlier in the encoding flow.")
      }

      data.withUnsafeBytes {
         messageWriter.write($0)
      }
   }

   private func encodeCount<T>(of array: [T], to messageWriter: inout MessageWriter) {
      encodeArrayCount(array.count, to: &messageWriter)
   }

   private func encodeCount<T>(of set: Set<T>, to messageWriter: inout MessageWriter) {
      encodeArrayCount(set.count, to: &messageWriter)
   }

   private func encodeArrayCount(_ arrayCount: Int, to messageWriter: inout MessageWriter) {
      let elementCount = arrayCount
      if let elementCount = UInt16(exactly: elementCount) {
         switch elementCount {
         case 0..<(1<<4):
            messageWriter.write(byte: 0b10010000 | UInt8(elementCount))

         default:
            messageWriter.write(byte: 0xdc)
            withUnsafeBytes(of: elementCount.bigEndian) {
               messageWriter.write($0)
            }
         }
      } else if let elementCount = UInt32(exactly: elementCount) {
         messageWriter.write(byte: 0xdd)
         withUnsafeBytes(of: elementCount.bigEndian) {
            messageWriter.write($0)
         }
      } else {
         preconditionFailure("Unsupported array element count \(elementCount) should have been blocked earlier in the encoding flow.")
      }
   }

   private func encodeCount<Key, Value>(of dictionary: [Key: Value], to messageWriter: inout MessageWriter) {
      let elementCount = dictionary.count
      if let elementCount = UInt16(exactly: elementCount) {
         switch elementCount {
         case 0..<(1<<4):
            messageWriter.write(byte: 0b10000000 | UInt8(elementCount))

         default:
            messageWriter.write(byte: 0xde)
            withUnsafeBytes(of: elementCount.bigEndian) {
               messageWriter.write($0)
            }
         }
      } else if let elementCount = UInt32(exactly: elementCount) {
         messageWriter.write(byte: 0xdf)
         withUnsafeBytes(of: elementCount.bigEndian) {
            messageWriter.write($0)
         }
      } else {
         preconditionFailure("Unsupported dictionary element count \(elementCount) should have been blocked earlier in the encoding flow.")
      }
   }

   private func encode(_ encodableAsExtension: any EncodableAsMessagePackExtension, to messageWriter: inout MessageWriter) {
      let byteCount = encodableAsExtension.encodedByteCount
      if let byteCount = UInt8(exactly: byteCount) {
         switch byteCount {
         case 1:
            messageWriter.write(byte: 0xd4)

         case 2:
            messageWriter.write(byte: 0xd5)

         case 4:
            messageWriter.write(byte: 0xd6)

         case 8:
            messageWriter.write(byte: 0xd7)

         case 16:
            messageWriter.write(byte: 0xd8)

         default:
            messageWriter.write(byte: 0xc7)
            messageWriter.write(byte: byteCount)
         }
      } else if let byteCount = UInt16(exactly: byteCount) {
         messageWriter.write(byte: 0xc8)
         withUnsafeBytes(of: byteCount.bigEndian) {
            messageWriter.write($0)
         }
      } else if let byteCount = UInt32(exactly: byteCount) {
         messageWriter.write(byte: 0xc9)
         withUnsafeBytes(of: byteCount.bigEndian) {
            messageWriter.write($0)
         }
      } else {
         preconditionFailure("Unsupported extension byte count \(byteCount) should have been blocked earlier in the encoding flow.")
      }

      messageWriter.write(byte: UInt8(bitPattern: type(of: encodableAsExtension).extensionTypeID))

      messageWriter.expectingWrites(byteCount: Int(byteCount)) { messageWriter in
         encodableAsExtension.encode(to: &messageWriter)
      }
   }
}
