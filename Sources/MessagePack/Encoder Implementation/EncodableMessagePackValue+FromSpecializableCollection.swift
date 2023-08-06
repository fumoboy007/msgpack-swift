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
   init?<T>(specializingCollection collection: T) {
      // Use the metatype to determine the collection type and extract the generic element type. Then,
      // check whether the generic element type matches a specializable element type. If a match was
      // found, cast the collection to the specific type and initialize `self`.
      //
      // An alternative that was considered was to `switch collection` and use `case let collection as …`.
      // That would be simpler from a code perspective. However, it could be incorrect and inefficient in
      // some cases.
      //
      // Regarding correctness, consider a dictionary with `AnyHashable` keys. Imagine the dictionary has
      // only one key: `true as AnyHashable`. Casting the dictionary to `[Int: …]` succeeds on Darwin
      // platforms because `Bool` is bridged to `NSNumber`, which can be cast to `Int`. This is undesirable
      // because we want to encode the original type.
      //
      // The above is also inefficient. Such casts iterate through each element in the collection in order
      // to determine whether the element can be cast to the desired element type. For example, see the
      // array cast implementation [1]. This `O(n)` operation would defeat the purpose of the specialization.
      //
      // [1]: https://github.com/apple/swift/blob/68e1ba0a84b9ff65c71e70bf24ab1009ba872680/stdlib/public/core/ArrayCast.swift#L68-L87

      guard let collectionType = StandardSwiftCollectionType(reflecting: type(of: collection)) else {
         return nil
      }

      switch collectionType {
      case .array(let elementType):
         self.init(specializingArray: collection, elementType: elementType)

      case .set(let elementType):
         self.init(specializingSet: collection, elementType: elementType)

      case .dictionary(let keyType, let valueType):
         self.init(specializingDictionary: collection, keyType: keyType, valueType: valueType)
      }
   }

   init?<T>(specializingArray array: T, elementType: Any.Type) {
      switch ObjectIdentifier(elementType) {
      case ObjectIdentifier(Bool.self):
         self = .boolArray(array as! [Bool])

      case ObjectIdentifier(Int.self):
         self = .intArray(array as! [Int])

      case ObjectIdentifier(Int8.self):
         self = .int8Array(array as! [Int8])

      case ObjectIdentifier(Int16.self):
         self = .int16Array(array as! [Int16])

      case ObjectIdentifier(Int32.self):
         self = .int32Array(array as! [Int32])

      case ObjectIdentifier(Int64.self):
         self = .int64Array(array as! [Int64])

      case ObjectIdentifier(UInt.self):
         self = .uintArray(array as! [UInt])

      case ObjectIdentifier(UInt8.self):
         self = .uint8Array(array as! [UInt8])

      case ObjectIdentifier(UInt16.self):
         self = .uint16Array(array as! [UInt16])

      case ObjectIdentifier(UInt32.self):
         self = .uint32Array(array as! [UInt32])

      case ObjectIdentifier(UInt64.self):
         self = .uint64Array(array as! [UInt64])

      case ObjectIdentifier(Float32.self):
         self = .float32Array(array as! [Float32])

      case ObjectIdentifier(Float64.self):
         self = .float64Array(array as! [Float64])

      case ObjectIdentifier(CGFloat.self):
         self = .cgFloatArray(array as! [CGFloat])

      case ObjectIdentifier(String.self):
         self = .stringArray(array as! [String])

      case ObjectIdentifier(Data.self):
         self = .dataArray(array as! [Data])

      case ObjectIdentifier(MessagePackTimestamp.self):
         self = .timestampArray(array as! [MessagePackTimestamp])

      default:
         return nil
      }
   }

   init?<T>(specializingSet set: T, elementType: Any.Type) {
      switch ObjectIdentifier(elementType) {
      case ObjectIdentifier(Bool.self):
         self = .boolSet(set as! Set<Bool>)

      case ObjectIdentifier(Int.self):
         self = .intSet(set as! Set<Int>)

      case ObjectIdentifier(Int8.self):
         self = .int8Set(set as! Set<Int8>)

      case ObjectIdentifier(Int16.self):
         self = .int16Set(set as! Set<Int16>)

      case ObjectIdentifier(Int32.self):
         self = .int32Set(set as! Set<Int32>)

      case ObjectIdentifier(Int64.self):
         self = .int64Set(set as! Set<Int64>)

      case ObjectIdentifier(UInt.self):
         self = .uintSet(set as! Set<UInt>)

      case ObjectIdentifier(UInt8.self):
         self = .uint8Set(set as! Set<UInt8>)

      case ObjectIdentifier(UInt16.self):
         self = .uint16Set(set as! Set<UInt16>)

      case ObjectIdentifier(UInt32.self):
         self = .uint32Set(set as! Set<UInt32>)

      case ObjectIdentifier(UInt64.self):
         self = .uint64Set(set as! Set<UInt64>)

      case ObjectIdentifier(Float32.self):
         self = .float32Set(set as! Set<Float32>)

      case ObjectIdentifier(Float64.self):
         self = .float64Set(set as! Set<Float64>)

      case ObjectIdentifier(CGFloat.self):
         self = .cgFloatSet(set as! Set<CGFloat>)

      case ObjectIdentifier(String.self):
         self = .stringSet(set as! Set<String>)

      case ObjectIdentifier(Data.self):
         self = .dataSet(set as! Set<Data>)

      case ObjectIdentifier(MessagePackTimestamp.self):
         self = .timestampSet(set as! Set<MessagePackTimestamp>)

      default:
         return nil
      }
   }

   init?<T>(specializingDictionary dictionary: T, keyType: Any.Type, valueType: Any.Type) {
      switch ObjectIdentifier(keyType) {
      case ObjectIdentifier(String.self):
         switch ObjectIdentifier(valueType) {
         case ObjectIdentifier(Bool.self):
            self = .stringToBoolMap(dictionary as! [String: Bool])

         case ObjectIdentifier(Int.self):
            self = .stringToIntMap(dictionary as! [String: Int])

         case ObjectIdentifier(Int8.self):
            self = .stringToInt8Map(dictionary as! [String: Int8])

         case ObjectIdentifier(Int16.self):
            self = .stringToInt16Map(dictionary as! [String: Int16])

         case ObjectIdentifier(Int32.self):
            self = .stringToInt32Map(dictionary as! [String: Int32])

         case ObjectIdentifier(Int64.self):
            self = .stringToInt64Map(dictionary as! [String: Int64])

         case ObjectIdentifier(UInt.self):
            self = .stringToUIntMap(dictionary as! [String: UInt])

         case ObjectIdentifier(UInt8.self):
            self = .stringToUInt8Map(dictionary as! [String: UInt8])

         case ObjectIdentifier(UInt16.self):
            self = .stringToUInt16Map(dictionary as! [String: UInt16])

         case ObjectIdentifier(UInt32.self):
            self = .stringToUInt32Map(dictionary as! [String: UInt32])

         case ObjectIdentifier(UInt64.self):
            self = .stringToUInt64Map(dictionary as! [String: UInt64])

         case ObjectIdentifier(Float32.self):
            self = .stringToFloat32Map(dictionary as! [String: Float32])

         case ObjectIdentifier(Float64.self):
            self = .stringToFloat64Map(dictionary as! [String: Float64])

         case ObjectIdentifier(CGFloat.self):
            self = .stringToCGFloatMap(dictionary as! [String: CGFloat])

         case ObjectIdentifier(String.self):
            self = .stringToStringMap(dictionary as! [String: String])

         case ObjectIdentifier(Data.self):
            self = .stringToDataMap(dictionary as! [String: Data])

         case ObjectIdentifier(MessagePackTimestamp.self):
            self = .stringToTimestampMap(dictionary as! [String: MessagePackTimestamp])

         default:
            return nil
         }

      case ObjectIdentifier(Int.self):
         switch ObjectIdentifier(valueType) {
         case ObjectIdentifier(Bool.self):
            self = .intToBoolMap(dictionary as! [Int: Bool])

         case ObjectIdentifier(Int.self):
            self = .intToIntMap(dictionary as! [Int: Int])

         case ObjectIdentifier(Int8.self):
            self = .intToInt8Map(dictionary as! [Int: Int8])

         case ObjectIdentifier(Int16.self):
            self = .intToInt16Map(dictionary as! [Int: Int16])

         case ObjectIdentifier(Int32.self):
            self = .intToInt32Map(dictionary as! [Int: Int32])

         case ObjectIdentifier(Int64.self):
            self = .intToInt64Map(dictionary as! [Int: Int64])

         case ObjectIdentifier(UInt.self):
            self = .intToUIntMap(dictionary as! [Int: UInt])

         case ObjectIdentifier(UInt8.self):
            self = .intToUInt8Map(dictionary as! [Int: UInt8])

         case ObjectIdentifier(UInt16.self):
            self = .intToUInt16Map(dictionary as! [Int: UInt16])

         case ObjectIdentifier(UInt32.self):
            self = .intToUInt32Map(dictionary as! [Int: UInt32])

         case ObjectIdentifier(UInt64.self):
            self = .intToUInt64Map(dictionary as! [Int: UInt64])

         case ObjectIdentifier(Float32.self):
            self = .intToFloat32Map(dictionary as! [Int: Float32])

         case ObjectIdentifier(Float64.self):
            self = .intToFloat64Map(dictionary as! [Int: Float64])

         case ObjectIdentifier(CGFloat.self):
            self = .intToCGFloatMap(dictionary as! [Int: CGFloat])

         case ObjectIdentifier(String.self):
            self = .intToStringMap(dictionary as! [Int: String])

         case ObjectIdentifier(Data.self):
            self = .intToDataMap(dictionary as! [Int: Data])

         case ObjectIdentifier(MessagePackTimestamp.self):
            self = .intToTimestampMap(dictionary as! [Int: MessagePackTimestamp])

         default:
            return nil
         }

      default:
         return nil
      }
   }
}
