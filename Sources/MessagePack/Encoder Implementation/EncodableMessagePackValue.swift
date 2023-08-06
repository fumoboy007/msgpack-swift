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

// Some rare cases are marked as `indirect` to reduce memory usage for the common cases.
//
// An enum uses at least as much memory as its largest associated value. The rare cases
// that are marked as `indirect` have an existential container as their associated value.
// An existential container is 40 bytes whereas the next largest associated value is
// 16 bytes.
enum EncodableMessagePackValue {
   // This case is rare. It is either used to throw a nested encoder error or when two
   // sibling nested encoders are in use simultaneously.
   indirect case future(any EncodableMessagePackValueFuture)

   case `nil`

   case boolean(Bool)

   case signedInteger(Int64)
   case unsignedInteger(UInt64)

   case float32(Float32)
   case float64(Float64)

   case string(String.UTF8View)
   case binary(Data)

   case array([EncodableMessagePackValue])

   case map([MessagePackKey: EncodableMessagePackValue])

   // This case is rare because application-specific extensions are rare. Predefined
   // extensions (e.g. timestamp) are specialized below.
   indirect case applicationSpecificExtension(any EncodableAsMessagePackExtension)

   // Specialized extensions
   case messagePackTimestamp(MessagePackTimestamp)

   // Specialized arrays
   case boolArray([Bool])
   case intArray([Int])
   case int8Array([Int8])
   case int16Array([Int16])
   case int32Array([Int32])
   case int64Array([Int64])
   case uintArray([UInt])
   case uint8Array([UInt8])
   case uint16Array([UInt16])
   case uint32Array([UInt32])
   case uint64Array([UInt64])
   case float32Array([Float32])
   case float64Array([Float64])
   case cgFloatArray([CGFloat])
   case stringArray([String])
   case dataArray([Data])
   case timestampArray([MessagePackTimestamp])

   // Specialized sets
   case boolSet(Set<Bool>)
   case intSet(Set<Int>)
   case int8Set(Set<Int8>)
   case int16Set(Set<Int16>)
   case int32Set(Set<Int32>)
   case int64Set(Set<Int64>)
   case uintSet(Set<UInt>)
   case uint8Set(Set<UInt8>)
   case uint16Set(Set<UInt16>)
   case uint32Set(Set<UInt32>)
   case uint64Set(Set<UInt64>)
   case float32Set(Set<Float32>)
   case float64Set(Set<Float64>)
   case cgFloatSet(Set<CGFloat>)
   case stringSet(Set<String>)
   case dataSet(Set<Data>)
   case timestampSet(Set<MessagePackTimestamp>)

   // Specialized maps
   case stringToBoolMap([String: Bool])
   case stringToIntMap([String: Int])
   case stringToInt8Map([String: Int8])
   case stringToInt16Map([String: Int16])
   case stringToInt32Map([String: Int32])
   case stringToInt64Map([String: Int64])
   case stringToUIntMap([String: UInt])
   case stringToUInt8Map([String: UInt8])
   case stringToUInt16Map([String: UInt16])
   case stringToUInt32Map([String: UInt32])
   case stringToUInt64Map([String: UInt64])
   case stringToFloat32Map([String: Float32])
   case stringToFloat64Map([String: Float64])
   case stringToCGFloatMap([String: CGFloat])
   case stringToStringMap([String: String])
   case stringToDataMap([String: Data])
   case stringToTimestampMap([String: MessagePackTimestamp])
   case intToBoolMap([Int: Bool])
   case intToIntMap([Int: Int])
   case intToInt8Map([Int: Int8])
   case intToInt16Map([Int: Int16])
   case intToInt32Map([Int: Int32])
   case intToInt64Map([Int: Int64])
   case intToUIntMap([Int: UInt])
   case intToUInt8Map([Int: UInt8])
   case intToUInt16Map([Int: UInt16])
   case intToUInt32Map([Int: UInt32])
   case intToUInt64Map([Int: UInt64])
   case intToFloat32Map([Int: Float32])
   case intToFloat64Map([Int: Float64])
   case intToCGFloatMap([Int: CGFloat])
   case intToStringMap([Int: String])
   case intToDataMap([Int: Data])
   case intToTimestampMap([Int: MessagePackTimestamp])
}
