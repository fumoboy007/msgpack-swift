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
   private static let maxStringUTF8ByteCount = 1<<32 - 1
   private static let maxBinaryByteCount = 1<<32 - 1
   private static let maxArrayElementCount = 1<<32 - 1
   private static let maxMapElementCount = 1<<32 - 1

   func validateForEncoding(at codingPath: @autoclosure () -> [any CodingKey]) throws {
      switch self {
      case .future,
            .nil,
            .boolean,
            .signedInteger,
            .unsignedInteger,
            .float32,
            .float64:
         break

      case .string(let utf8):
         try Self.validate(utf8, forEncodingAt: codingPath)

      case .binary(let data):
         try Self.validate(data, forEncodingAt: codingPath)

      case .array(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .applicationSpecificExtension(let encodableAsExtension):
         let metatype = type(of: encodableAsExtension)
         let typeID = metatype.extensionTypeID
         if let predefinedExtensionMetatype = PredefinedExtensions.typeIDToMetatype[typeID] {
            guard metatype == predefinedExtensionMetatype else {
               let context = EncodingError.Context(codingPath: codingPath(),
                                                   debugDescription: "Application-specific extension has type \(typeID), which conflicts with the predefined extension `\(predefinedExtensionMetatype)`.")
               throw EncodingError.invalidValue(encodableAsExtension, context)
            }
         } else {
            guard !PredefinedExtensions.typeIDRange.contains(typeID) else {
               let context = EncodingError.Context(codingPath: codingPath(),
                                                   debugDescription: "Application-specific extension has type \(typeID), which is reserved for predefined extensions.")
               throw EncodingError.invalidValue(encodableAsExtension, context)
            }
         }

         try Self.validate(encodableAsExtension, forEncodingAt: codingPath)

      case .messagePackTimestamp(let messagePackTimestamp):
         try Self.validate(messagePackTimestamp, forEncodingAt: codingPath)

      case .boolArray(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .intArray(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .int8Array(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .int16Array(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .int32Array(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .int64Array(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .uintArray(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .uint8Array(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .uint16Array(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .uint32Array(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .uint64Array(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .float32Array(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .float64Array(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .cgFloatArray(let array):
         try Self.validate(array, forEncodingAt: codingPath)

      case .stringArray(let array):
         try Self.validate(array, forEncodingAt: codingPath)

         for value in array {
            try Self.validate(value.utf8, forEncodingAt: codingPath)
         }

      case .dataArray(let array):
         try Self.validate(array, forEncodingAt: codingPath)

         for value in array {
            try Self.validate(value, forEncodingAt: codingPath)
         }

      case .timestampArray(let array):
         try Self.validate(array, forEncodingAt: codingPath)

         for value in array {
            try Self.validate(value, forEncodingAt: codingPath)
         }

      case .boolSet(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .intSet(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .int8Set(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .int16Set(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .int32Set(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .int64Set(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .uintSet(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .uint8Set(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .uint16Set(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .uint32Set(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .uint64Set(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .float32Set(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .float64Set(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .cgFloatSet(let set):
         try Self.validate(set, forEncodingAt: codingPath)

      case .stringSet(let set):
         try Self.validate(set, forEncodingAt: codingPath)

         for value in set {
            try Self.validate(value.utf8, forEncodingAt: codingPath)
         }

      case .dataSet(let set):
         try Self.validate(set, forEncodingAt: codingPath)

         for value in set {
            try Self.validate(value, forEncodingAt: codingPath)
         }

      case .timestampSet(let set):
         try Self.validate(set, forEncodingAt: codingPath)

         for value in set {
            try Self.validate(value, forEncodingAt: codingPath)
         }

      case .stringToBoolMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToIntMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToInt8Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToInt16Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToInt32Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToInt64Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToUIntMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToUInt8Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToUInt16Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToUInt32Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToUInt64Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToFloat32Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToFloat64Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToCGFloatMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for key in dictionary.keys {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
         }

      case .stringToStringMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for (key, value) in dictionary {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
            try Self.validate(value.utf8, forEncodingAt: codingPath)
         }

      case .stringToDataMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for (key, value) in dictionary {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
            try Self.validate(value, forEncodingAt: codingPath)
         }

      case .stringToTimestampMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for (key, value) in dictionary {
            try Self.validate(key.utf8, forEncodingAt: codingPath)
            try Self.validate(value, forEncodingAt: codingPath)
         }

      case .intToBoolMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToIntMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToInt8Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToInt16Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToInt32Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToInt64Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToUIntMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToUInt8Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToUInt16Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToUInt32Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToUInt64Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToFloat32Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToFloat64Map(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToCGFloatMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

      case .intToStringMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for value in dictionary.values {
            try Self.validate(value.utf8, forEncodingAt: codingPath)
         }

      case .intToDataMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for value in dictionary.values {
            try Self.validate(value, forEncodingAt: codingPath)
         }

      case .intToTimestampMap(let dictionary):
         try Self.validate(dictionary, forEncodingAt: codingPath)

         for value in dictionary.values {
            try Self.validate(value, forEncodingAt: codingPath)
         }
      }
   }

   private static func validate(_ utf8: String.UTF8View,
                                forEncodingAt codingPath: () -> [any CodingKey]) throws {
      let actualCount = utf8.count
      let maxCount = maxStringUTF8ByteCount
      guard actualCount <= maxCount else {
         let context = EncodingError.Context(codingPath: codingPath(),
                                             debugDescription: "String has \(actualCount) UTF-8 bytes but MessagePack only supports a maximum of \(maxCount) bytes.")
         throw EncodingError.invalidValue(String(utf8), context)
      }
   }

   private static func validate(_ data: Data,
                                forEncodingAt codingPath: () -> [any CodingKey]) throws {
      let actualCount = data.count
      let maxCount = maxBinaryByteCount
      guard actualCount <= maxCount else {
         let context = EncodingError.Context(codingPath: codingPath(),
                                             debugDescription: "Data has \(actualCount) bytes but MessagePack only supports a maximum of \(maxCount) bytes.")
         throw EncodingError.invalidValue(data, context)
      }
   }

   private static func validate(_ encodableAsExtension: any EncodableAsMessagePackExtension,
                                forEncodingAt codingPath: () -> [any CodingKey]) throws {
      do {
         try encodableAsExtension.validateForEncoding()
      } catch {
         let context = EncodingError.Context(codingPath: codingPath(),
                                             debugDescription: "Extension validation failed.",
                                             underlyingError: error)
         throw EncodingError.invalidValue(encodableAsExtension, context)
      }
   }

   private static func validate<T>(_ array: [T],
                                   forEncodingAt codingPath: () -> [any CodingKey]) throws {
      try validateArrayCount(array.count, forEncodingAt: codingPath)
   }

   private static func validate<T>(_ set: Set<T>,
                                   forEncodingAt codingPath: () -> [any CodingKey]) throws {
      try validateArrayCount(set.count, forEncodingAt: codingPath)
   }

   private static func validateArrayCount(_ arrayCount: Int,
                                          forEncodingAt codingPath: () -> [any CodingKey]) throws {
      let actualCount = arrayCount
      let maxCount = maxArrayElementCount
      guard actualCount <= maxCount else {
         let context = EncodingError.Context(codingPath: codingPath(),
                                             debugDescription: "Array has \(actualCount) elements but MessagePack only supports a maximum of \(maxCount) elements.")
         throw EncodingError.invalidValue(array, context)
      }
   }

   private static func validate<Key, Value>(_ dictionary: [Key: Value],
                                            forEncodingAt codingPath: () -> [any CodingKey]) throws {
      let actualCount = dictionary.count
      let maxCount = maxMapElementCount
      guard actualCount <= maxCount else {
         let context = EncodingError.Context(codingPath: codingPath(),
                                             debugDescription: "Dictionary has \(actualCount) elements but MessagePack only supports a maximum of \(maxCount) elements.")
         throw EncodingError.invalidValue(dictionary, context)
      }
   }
}
