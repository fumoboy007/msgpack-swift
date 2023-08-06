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

/// Represents an array that was decoded from MessagePack bytes.
///
/// MessagePack arrays are heterogeneous—even if the source array itself was homogeneous.
/// However, Swift arrays are homogeneous. This type provides an API to extract a
/// homogeneous array from the MessagePack array, if possible. It also provides access
/// to the individual elements for the case where the array is used as an unkeyed container.
class DecodedMessagePackArray {
   private let minimumCapacity: Int

   private enum ElementType {
      case bool
      case int64
      case float64
      case string
      case data
      case timestamp
   }

   private var boolArray: [Bool]?
   // Represent all decoded integers as `Int64`.
   //
   // The MessagePack specification encourages encoder implementations to use the smallest data
   // type for a given value. Thus, we generally cannot determine the element type for an integer
   // array using just the first two elements as we can with non-integer arrays.
   //
   // Therefore, use a 64-bit integer since it can represent all values of smaller data types.
   // Use `Int64` instead of `UInt64` because negative numbers are much more common than numbers
   // greater than `Int64.max`.
   private var int64Array: [Int64]?
   // Represent all decoded floating point values as `Float64`.
   //
   // The MessagePack specification encourages encoder implementations to use the smallest data
   // type for a given value. Thus, we generally cannot determine the element type for a floating
   // point array using just the first two elements as we can with non-floating-point arrays.
   //
   // Therefore, use `Float64` since it can represent all values of `Float32` precisely, aside
   // from NaN values.
   private var float64Array: [Float64]?
   private var stringArray: [String]?
   private var dataArray: [Data]?
   private var timestampArray: [MessagePackTimestamp]?

   private var heterogeneousArray: [DecodedMessagePackValue]?

   private enum State {
      case empty

      case singleElement(DecodedMessagePackValue)

      // Attempt to store elements in an underlying homogeneous array. Although we could instead
      // store elements in a heterogeneous array and then convert to a homogeneous array on demand,
      // storing in a homogeneous array reduces memory usage and avoids an array copy in many cases.
      case multipleHomogeneousElements(ElementType)

      // If the array turns out to be truly heterogeneous, then store new elements in a heterogeneous
      // array while keeping existing elements in the prior homogeneous array, if any.
      case multipleHeterogeneousElements(previousHomogeneousElementType: ElementType?)
   }
   private var state = State.empty

   init(minimumCapacity: Int) {
      self.minimumCapacity = minimumCapacity
   }
}

extension DecodedMessagePackArray {
   var count: Int {
      switch state {
      case .empty:
         return 0

      case .singleElement:
         return 1

      case .multipleHomogeneousElements(let elementType):
         return homogeneousElementCount(of: elementType)

      case .multipleHeterogeneousElements(let previousHomogeneousElementType):
         var count = heterogeneousArray!.count

         if let previousHomogeneousElementType {
            count += homogeneousElementCount(of: previousHomogeneousElementType)
         }

         return count
      }
   }

   private func homogeneousElementCount(of elementType: ElementType) -> Int {
      switch elementType {
      case .bool:
         return boolArray!.count

      case .int64:
         return int64Array!.count

      case .float64:
         return float64Array!.count

      case .string:
         return stringArray!.count

      case .data:
         return dataArray!.count

      case .timestamp:
         return timestampArray!.count
      }
   }
}

extension DecodedMessagePackArray {
   func append(_ newElement: DecodedMessagePackValue) {
      switch state {
      case .empty:
         state = .singleElement(newElement)

      case .singleElement(let firstElement):
         transitionToMultipleElementsState(firstElement: firstElement,
                                           secondElement: newElement)

      case .multipleHomogeneousElements(let elementType):
         if !append(newElement, toHomogeneousArrayOf: elementType) {
            transitionToMultipleHeterogeneousElementsState(previousHomogeneousElementType: elementType,
                                                           firstHeterogeneousElement: newElement,
                                                           secondHeterogeneousElement: nil)
         }

      case .multipleHeterogeneousElements:
         heterogeneousArray!.append(newElement)
      }
   }

   private func transitionToMultipleElementsState(firstElement: DecodedMessagePackValue,
                                                  secondElement: DecodedMessagePackValue) {
      switch (firstElement, secondElement) {
      case (.boolean(let firstElement), .boolean(let secondElement)):
         initializeHomogeneousArray(&boolArray,
                                    firstElement: firstElement,
                                    secondElement: secondElement)
         state = .multipleHomogeneousElements(.bool)

      case (.signedInteger(let firstElement), .signedInteger(let secondElement)):
         transitionToMultipleInt64ElementsState(firstElement: firstElement,
                                                secondElement: secondElement)

      case (.signedInteger(let firstInteger), .unsignedInteger(let secondInteger)):
         if let secondInteger = Int64(exactly: secondInteger) {
            transitionToMultipleInt64ElementsState(firstElement: firstInteger,
                                                   secondElement: secondInteger)
         } else {
            transitionToMultipleHeterogeneousElementsState(previousHomogeneousElementType: nil,
                                                           firstHeterogeneousElement: firstElement,
                                                           secondHeterogeneousElement: secondElement)
         }

      case (.unsignedInteger(let firstInteger), .unsignedInteger(let secondInteger)):
         if let firstInteger = Int64(exactly: firstInteger), let secondInteger = Int64(exactly: secondInteger) {
            transitionToMultipleInt64ElementsState(firstElement: firstInteger,
                                                   secondElement: secondInteger)
         } else {
            transitionToMultipleHeterogeneousElementsState(previousHomogeneousElementType: nil,
                                                           firstHeterogeneousElement: firstElement,
                                                           secondHeterogeneousElement: secondElement)
         }

      case (.unsignedInteger(let firstInteger), .signedInteger(let secondInteger)):
         if let firstInteger = Int64(exactly: firstInteger) {
            transitionToMultipleInt64ElementsState(firstElement: firstInteger,
                                                   secondElement: secondInteger)
         } else {
            transitionToMultipleHeterogeneousElementsState(previousHomogeneousElementType: nil,
                                                           firstHeterogeneousElement: firstElement,
                                                           secondHeterogeneousElement: secondElement)
         }

      case (.float32(let firstFloatingPoint), .float32(let secondFloatingPoint)):
         if let firstFloatingPoint = Float64(exactly: firstFloatingPoint),
            let secondFloatingPoint = Float64(exactly: secondFloatingPoint) {
            transitionToMultipleFloat64ElementsState(firstElement: firstFloatingPoint,
                                                     secondElement: secondFloatingPoint)
         } else {
            transitionToMultipleHeterogeneousElementsState(previousHomogeneousElementType: nil,
                                                           firstHeterogeneousElement: firstElement,
                                                           secondHeterogeneousElement: secondElement)
         }

      case (.float32(let firstFloatingPoint), .float64(let secondFloatingPoint)):
         if let firstFloatingPoint = Float64(exactly: firstFloatingPoint) {
            transitionToMultipleFloat64ElementsState(firstElement: firstFloatingPoint,
                                                     secondElement: secondFloatingPoint)
         } else {
            transitionToMultipleHeterogeneousElementsState(previousHomogeneousElementType: nil,
                                                           firstHeterogeneousElement: firstElement,
                                                           secondHeterogeneousElement: secondElement)
         }

      case (.float64(let firstElement), .float64(let secondElement)):
         transitionToMultipleFloat64ElementsState(firstElement: firstElement,
                                                  secondElement: secondElement)

      case (.float64(let firstFloatingPoint), .float32(let secondFloatingPoint)):
         if let secondFloatingPoint = Float64(exactly: secondFloatingPoint) {
            transitionToMultipleFloat64ElementsState(firstElement: firstFloatingPoint,
                                                     secondElement: secondFloatingPoint)
         } else {
            transitionToMultipleHeterogeneousElementsState(previousHomogeneousElementType: nil,
                                                           firstHeterogeneousElement: firstElement,
                                                           secondHeterogeneousElement: secondElement)
         }

      case (.string(let firstElement), .string(let secondElement)):
         initializeHomogeneousArray(&stringArray,
                                    firstElement: firstElement,
                                    secondElement: secondElement)
         state = .multipleHomogeneousElements(.string)

      case (.binary(let firstElement), .binary(let secondElement)):
         initializeHomogeneousArray(&dataArray,
                                    firstElement: firstElement,
                                    secondElement: secondElement)
         state = .multipleHomogeneousElements(.data)

      case (.messagePackTimestamp(let firstElement), .messagePackTimestamp(let secondElement)):
         initializeHomogeneousArray(&timestampArray,
                                    firstElement: firstElement,
                                    secondElement: secondElement)
         state = .multipleHomogeneousElements(.timestamp)

      default:
         transitionToMultipleHeterogeneousElementsState(previousHomogeneousElementType: nil,
                                                        firstHeterogeneousElement: firstElement,
                                                        secondHeterogeneousElement: secondElement)
      }
   }

   private func transitionToMultipleInt64ElementsState(firstElement: Int64, secondElement: Int64) {
      initializeHomogeneousArray(&int64Array,
                                 firstElement: firstElement,
                                 secondElement: secondElement)
      state = .multipleHomogeneousElements(.int64)
   }

   private func transitionToMultipleFloat64ElementsState(firstElement: Float64, secondElement: Float64) {
      initializeHomogeneousArray(&float64Array,
                                 firstElement: firstElement,
                                 secondElement: secondElement)
      state = .multipleHomogeneousElements(.float64)
   }

   private func initializeHomogeneousArray<T>(
      _ targetArray: inout [T]?,
      firstElement: T,
      secondElement: T
   ) {
      precondition(targetArray == nil)

      var array = [T]()
      array.reserveCapacity(minimumCapacity)

      array.append(firstElement)
      array.append(secondElement)

      targetArray = array
   }

   private func append(_ newElement: DecodedMessagePackValue,
                       toHomogeneousArrayOf elementType: ElementType) -> Bool {
      switch newElement {
      case .boolean(let newElement):
         guard case .bool = elementType else {
            return false
         }
         boolArray!.append(newElement)

      case .signedInteger(let newElement):
         guard case .int64 = elementType else {
            return false
         }

         int64Array!.append(newElement)

      case .unsignedInteger(let newElement):
         guard case .int64 = elementType else {
            return false
         }
         guard let newElement = Int64(exactly: newElement) else {
            return false
         }
         int64Array!.append(newElement)

      case .float32(let newElement):
         guard case .float64 = elementType else {
            return false
         }
         guard let newElement = Float64(exactly: newElement) else {
            return false
         }
         float64Array!.append(newElement)

      case .float64(let newElement):
         guard case .float64 = elementType else {
            return false
         }
         float64Array!.append(newElement)

      case .string(let newElement):
         guard case .string = elementType else {
            return false
         }
         stringArray!.append(newElement)

      case .binary(let newElement):
         guard case .data = elementType else {
            return false
         }
         dataArray!.append(newElement)

      case .messagePackTimestamp(let newElement):
         guard case .timestamp = elementType else {
            return false
         }
         timestampArray!.append(newElement)

      case .invalid,
            .nil,
            .array,
            .map,
            .applicationSpecificExtension,
            .unknownExtension:
         return false
      }

      return true
   }

   private func transitionToMultipleHeterogeneousElementsState(
      previousHomogeneousElementType: ElementType?,
      firstHeterogeneousElement: DecodedMessagePackValue,
      secondHeterogeneousElement: DecodedMessagePackValue?
   ) {
      precondition(heterogeneousArray == nil)

      var heterogeneousArray = [DecodedMessagePackValue]()

      var minimumCapacity = minimumCapacity
      if let previousHomogeneousElementType {
         minimumCapacity = max(minimumCapacity - homogeneousElementCount(of: previousHomogeneousElementType), 0)
      }
      heterogeneousArray.reserveCapacity(minimumCapacity)

      heterogeneousArray.append(firstHeterogeneousElement)
      if let secondHeterogeneousElement {
         heterogeneousArray.append(secondHeterogeneousElement)
      }

      self.heterogeneousArray = heterogeneousArray
      state = .multipleHeterogeneousElements(previousHomogeneousElementType: previousHomogeneousElementType)
   }
}

extension DecodedMessagePackArray {
   func homogeneousArray(of targetElementType: Any.Type) -> Any? {
      switch state {
      case .empty:
         return [Any]()

      case .singleElement(let element):
         return homogeneousArray(with: element, of: targetElementType)

      case .multipleHomogeneousElements(let elementType):
         return homogeneousArray(of: targetElementType, from: elementType)

      case .multipleHeterogeneousElements:
         return nil
      }
   }

   private func homogeneousArray(with element: DecodedMessagePackValue, of targetElementType: Any.Type) -> Any? {
      switch element {
      case .boolean(let element):
         guard targetElementType == Bool.self else {
            return nil
         }
         return [element]

      case .signedInteger(let element):
         return integerArray(with: element, of: targetElementType)

      case .unsignedInteger(let element):
         return integerArray(with: element, of: targetElementType)

      case .float32(let element):
         return floatingPointArray(with: element, of: targetElementType)

      case .float64(let element):
         return floatingPointArray(with: element, of: targetElementType)

      case .string(let element):
         guard targetElementType == String.self else {
            return nil
         }
         return [element]

      case .binary(let element):
         guard targetElementType == Data.self else {
            return nil
         }
         return [element]

      case .messagePackTimestamp(let element):
         guard targetElementType == MessagePackTimestamp.self else {
            return nil
         }
         return [element]

      case .invalid,
            .nil,
            .array,
            .map,
            .applicationSpecificExtension,
            .unknownExtension:
         return nil
      }
   }

   private func integerArray<T: BinaryInteger>(with element: T, of targetElementType: Any.Type) -> Any? {
      switch targetElementType {
      case is Int.Type:
         guard let element = Int(exactly: element) else {
            return nil
         }
         return [element]

      case is Int8.Type:
         guard let element = Int8(exactly: element) else {
            return nil
         }
         return [element]

      case is Int16.Type:
         guard let element = Int16(exactly: element) else {
            return nil
         }
         return [element]

      case is Int32.Type:
         guard let element = Int32(exactly: element) else {
            return nil
         }
         return [element]

      case is Int64.Type:
         guard let element = Int64(exactly: element) else {
            return nil
         }
         return [element]

      case is UInt.Type:
         guard let element = UInt(exactly: element) else {
            return nil
         }
         return [element]

      case is UInt8.Type:
         guard let element = UInt8(exactly: element) else {
            return nil
         }
         return [element]

      case is UInt16.Type:
         guard let element = UInt16(exactly: element) else {
            return nil
         }
         return [element]

      case is UInt32.Type:
         guard let element = UInt32(exactly: element) else {
            return nil
         }
         return [element]

      case is UInt64.Type:
         guard let element = UInt64(exactly: element) else {
            return nil
         }
         return [element]

      default:
         return nil
      }
   }

   private func floatingPointArray<T: BinaryFloatingPoint>(with element: T, of targetElementType: Any.Type) -> Any? {
      switch targetElementType {
      case is Float64.Type:
         guard let element = Float64(exactly: element) else {
            return nil
         }
         return [element]

      case is Float32.Type:
         guard let element = Float32(exactly: element) else {
            return nil
         }
         return [element]

      case is CGFloat.Type:
         guard let element = CGFloat(exactly: element) else {
            return nil
         }
         return [element]

      default:
         return nil
      }
   }

   private func homogeneousArray(of targetElementType: Any.Type, from currentElementType: ElementType) -> Any? {
      switch currentElementType {
      case .bool:
         guard targetElementType == Bool.self else {
            return nil
         }
         return boolArray!

      case .int64:
         switch targetElementType {
         case is Int.Type:
            return integerArray(of: Int.self)

         case is Int8.Type:
            return integerArray(of: Int8.self)

         case is Int16.Type:
            return integerArray(of: Int16.self)

         case is Int32.Type:
            return integerArray(of: Int32.self)

         case is Int64.Type:
            return int64Array!

         case is UInt.Type:
            return integerArray(of: UInt.self)

         case is UInt8.Type:
            return integerArray(of: UInt8.self)

         case is UInt16.Type:
            return integerArray(of: UInt16.self)

         case is UInt32.Type:
            return integerArray(of: UInt32.self)

         case is UInt64.Type:
            return integerArray(of: UInt64.self)

         default:
            return nil
         }

      case .float64:
         switch targetElementType {
         case is Float64.Type:
            return float64Array!

         case is Float32.Type:
            return floatingPointArray(of: Float32.self)

         case is CGFloat.Type:
            return floatingPointArray(of: CGFloat.self)

         default:
            return nil
         }

      case .string:
         guard targetElementType == String.self else {
            return nil
         }
         return stringArray!

      case .data:
         guard targetElementType == Data.self else {
            return nil
         }
         return dataArray!

      case .timestamp:
         guard targetElementType == MessagePackTimestamp.self else {
            return nil
         }
         return timestampArray!
      }
   }

   private func integerArray<T: BinaryInteger>(of elementType: T.Type) -> [T]? {
      if elementType == Int.self && Int.bitWidth == Int64.bitWidth {
         return intArrayFromInt64Array() as? [T]
      }

      var array = [T]()
      array.reserveCapacity(int64Array!.count)

      for element in int64Array! {
         guard let element = elementType.init(exactly: element) else {
            return nil
         }
         array.append(element)
      }

      return array
   }

   private func intArrayFromInt64Array() -> [Int] {
      precondition(Int.bitWidth == Int64.bitWidth)

      let elementCount = int64Array!.count

      return [Int](unsafeUninitializedCapacity: elementCount) { (intBuffer, initializedCount) in
         guard let destination = intBuffer.baseAddress else {
            return
         }

         int64Array!.withUnsafeBufferPointer { int64Buffer in
            guard let source = int64Buffer.baseAddress else {
               return
            }

            source.withMemoryRebound(to: Int.self, capacity: elementCount) {
               destination.initialize(from: $0, count: elementCount)
            }

            initializedCount = elementCount
         }
      }
   }

   private func floatingPointArray<T: BinaryFloatingPoint>(of elementType: T.Type) -> [T]? {
      if elementType == CGFloat.self && CGFloat.NativeType.self == Double.self {
         return cgFloatArrayFromFloat64Array() as? [T]
      }

      var array = [T]()
      array.reserveCapacity(float64Array!.count)

      for element in float64Array! {
         guard let element = elementType.init(exactly: element) else {
            return nil
         }
         array.append(element)
      }

      return array
   }

   private func cgFloatArrayFromFloat64Array() -> [CGFloat] {
      precondition(CGFloat.NativeType.self == Double.self)

      let elementCount = float64Array!.count

      return [CGFloat](unsafeUninitializedCapacity: elementCount) { (cgFloatBuffer, initializedCount) in
         guard let destination = cgFloatBuffer.baseAddress else {
            return
         }

         float64Array!.withUnsafeBufferPointer { float64Buffer in
            guard let source = float64Buffer.baseAddress else {
               return
            }

            source.withMemoryRebound(to: CGFloat.self, capacity: elementCount) {
               destination.initialize(from: $0, count: elementCount)
            }

            initializedCount = elementCount
         }
      }
   }
}

extension DecodedMessagePackArray {
   subscript(index: Int) -> DecodedMessagePackValue {
      switch state {
      case .empty:
         preconditionFailure("No elements in array.")

      case .singleElement(let element):
         precondition(index == 0)
         return element

      case .multipleHomogeneousElements(let elementType):
         return homogeneousElement(of: elementType, at: index)

      case .multipleHeterogeneousElements(let previousHomogeneousElementType):
         var homogeneousElementCount = 0
         if let previousHomogeneousElementType {
            homogeneousElementCount = self.homogeneousElementCount(of: previousHomogeneousElementType)

            if index < homogeneousElementCount {
               return homogeneousElement(of: previousHomogeneousElementType, at: index)
            }
         }

         return heterogeneousArray![index - homogeneousElementCount]
      }
   }

   private func homogeneousElement(of elementType: ElementType, at index: Int) -> DecodedMessagePackValue {
      switch elementType {
      case .bool:
         return .boolean(boolArray![index])

      case .int64:
         return .signedInteger(int64Array![index])

      case .float64:
         return .float64(float64Array![index])

      case .string:
         return .string(stringArray![index])

      case .data:
         return .binary(dataArray![index])

      case .timestamp:
         return .messagePackTimestamp(timestampArray![index])
      }
   }
}
