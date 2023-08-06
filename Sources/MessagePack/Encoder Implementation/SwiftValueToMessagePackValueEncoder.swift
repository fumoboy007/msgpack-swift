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

final class SwiftValueToMessagePackValueEncoder {
   // Copied from the `JSONEncoder` implementation. I assume Apple tuned this number for optimal performance:
   // https://github.com/apple/swift-corelibs-foundation/blob/8ff7ba31420c0b71ea87984c26cd867b4bcb7c90/Sources/Foundation/JSONEncoder.swift#L299
   private static let initialDictionaryCapacity = 20

   // Copied from the `JSONEncoder` implementation. I assume Apple tuned this number for optimal performance:
   // https://github.com/apple/swift-corelibs-foundation/blob/8ff7ba31420c0b71ea87984c26cd867b4bcb7c90/Sources/Foundation/JSONEncoder.swift#L256
   private static let initialArrayCapacity = 10

   private(set) var codingPath: [any CodingKey]

   let userInfo: [CodingUserInfoKey: Any]

   private var dictionary: [MessagePackKey: EncodableMessagePackValue]?
   private var array: [EncodableMessagePackValue]?
   private var singleValue: EncodableMessagePackValue?

   private var reusableNestedEncoder: SwiftValueToMessagePackValueEncoder?
   private enum ReusableNestedEncoderState {
      case idle
      case pendingInsertionIntoDictionary(MessagePackKey)
      case pendingInsertionIntoArray
      case pendingStorageAsSingleValue
   }
   private var reusableNestedEncoderState = ReusableNestedEncoderState.idle

   init(codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey: Any]) {
      self.codingPath = codingPath
      self.userInfo = userInfo
   }

   private func reset(replacingCodingKeyAtIndex codingPathIndexToReplace: Int,
                      with newCodingKey: (any CodingKey)?) {
      if let newCodingKey {
         codingPath.replaceSubrange(codingPathIndexToReplace...,
                                    with: CollectionOfOne(newCodingKey))
      } else {
         codingPath.removeSubrange(codingPathIndexToReplace...)
      }

      dictionary = nil
      array = nil
      singleValue = nil

      switch reusableNestedEncoderState {
      case .idle:
         break

      case .pendingInsertionIntoDictionary,
            .pendingInsertionIntoArray,
            .pendingStorageAsSingleValue:
         preconditionFailure("This nested encoder is not ready for reuse because its own nested encoder has not been finalized.")
      }
   }

   private func codingPath(appending codingKey: any CodingKey) -> [any CodingKey] {
      var codingPath = codingPath
      codingPath.append(codingKey)

      return codingPath
   }

   private func finishInsertingInUseNestedEncoderIfNeeded() {
      switch reusableNestedEncoderState {
      case .idle:
         return

      case .pendingInsertionIntoDictionary(let messagePackKey):
         dictionary![messagePackKey] = finalizeInUseNestedEncoder()

      case .pendingInsertionIntoArray:
         array!.append(finalizeInUseNestedEncoder())

      case .pendingStorageAsSingleValue:
         store(finalizeInUseNestedEncoder())
      }
   }

   private func finalizeInUseNestedEncoder() -> EncodableMessagePackValue {
      reusableNestedEncoderState = .idle

      if isKnownUniquelyReferenced(&reusableNestedEncoder) {
         do {
            return try reusableNestedEncoder!.encodableMessagePackValue
         } catch {
            return .future(FailedEncodableMessagePackValueFuture(error: error))
         }
      } else {
         let messagePackValue = EncodableMessagePackValue.future(reusableNestedEncoder!)

         reusableNestedEncoder = nil

         return messagePackValue
      }
   }

   private func reuseNestedEncoder(for codingKey: (any CodingKey)?,
                                   transitioningTo newState: ReusableNestedEncoderState) -> SwiftValueToMessagePackValueEncoder {
      let nestedEncoder: SwiftValueToMessagePackValueEncoder
      if let reusableNestedEncoder {
         resetIdleNestedEncoder(replacingLastCodingKeyWith: codingKey)

         nestedEncoder = reusableNestedEncoder
      } else {
         var nestedCodingPath = codingPath
         if let codingKey {
            nestedCodingPath.append(codingKey)
         }

         nestedEncoder = Self(codingPath: nestedCodingPath,
                              userInfo: userInfo)

         reusableNestedEncoder = nestedEncoder
      }

      reusableNestedEncoderState = newState

      return nestedEncoder
   }

   private func resetIdleNestedEncoder(replacingLastCodingKeyWith newCodingKey: (any CodingKey)?) {
      switch reusableNestedEncoderState {
      case .idle:
         break

      case .pendingInsertionIntoDictionary,
            .pendingInsertionIntoArray,
            .pendingStorageAsSingleValue:
         preconditionFailure("Nested encoder is not idle.")
      }

      reusableNestedEncoder!.reset(replacingCodingKeyAtIndex: codingPath.count,
                                   with: newCodingKey)
   }
}

extension SwiftValueToMessagePackValueEncoder: EncodableMessagePackValueFuture {
   var encodableMessagePackValue: EncodableMessagePackValue {
      get throws {
         finishInsertingInUseNestedEncoderIfNeeded()

         let value: EncodableMessagePackValue
         if let dictionary {
            value = .map(dictionary)
         } else if let array {
            value = .array(array)
         } else if let singleValue {
            value = singleValue
         } else {
            preconditionFailure("No values encoded at coding path `\(codingPath)`.")
         }

         try value.validateForEncoding(at: codingPath)

         return value
      }
   }
}

extension SwiftValueToMessagePackValueEncoder: Encoder {
   func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
      precondition(array == nil && singleValue == nil,
                   "Found existing top-level encoding container at coding path `\(codingPath)`.")

      if dictionary == nil {
         dictionary = Dictionary(minimumCapacity: Self.initialDictionaryCapacity)
      }

      return KeyedEncodingContainer(KeyedMessagePackEncodingContainer(encoder: self))
   }

   func unkeyedContainer() -> UnkeyedEncodingContainer {
      precondition(dictionary == nil && singleValue == nil,
                   "Found existing top-level encoding container at coding path `\(codingPath)`.")

      if array == nil {
         var array = [EncodableMessagePackValue]()
         array.reserveCapacity(Self.initialArrayCapacity)
         self.array = array
      }

      return UnkeyedMessagePackEncodingContainer(encoder: self)
   }

   func singleValueContainer() -> SingleValueEncodingContainer {
      precondition(dictionary == nil && array == nil,
                   "Found existing top-level encoding container at coding path `\(codingPath)`.")

      return SingleValueMessagePackEncodingContainer(encoder: self)
   }
}

extension SwiftValueToMessagePackValueEncoder {
   func set<Key: CodingKey>(_ value: EncodableMessagePackValue, for codingKey: Key) throws {
      try value.validateForEncoding(at: codingPath(appending: codingKey))

      finishInsertingInUseNestedEncoderIfNeeded()

      dictionary![MessagePackKey(codingKey)] = value
   }

   func nestedEncoder<Key: CodingKey>(for codingKey: Key) -> SwiftValueToMessagePackValueEncoder {
      finishInsertingInUseNestedEncoderIfNeeded()

      return reuseNestedEncoder(for: codingKey,
                                transitioningTo: .pendingInsertionIntoDictionary(MessagePackKey(codingKey)))
   }
}

extension SwiftValueToMessagePackValueEncoder {
   var arrayCount: Int {
      return array!.count
   }

   func append(_ value: EncodableMessagePackValue) throws {
      try value.validateForEncoding(at: codingPathForCurrentArrayIndex)

      finishInsertingInUseNestedEncoderIfNeeded()

      array!.append(value)
   }

   func nextNestedEncoder() -> SwiftValueToMessagePackValueEncoder {
      finishInsertingInUseNestedEncoderIfNeeded()

      return reuseNestedEncoder(for: InternalCodingKey.arrayIndex(arrayCount),
                                transitioningTo: .pendingInsertionIntoArray)
   }

   private var codingPathForCurrentArrayIndex: [any CodingKey] {
      let codingKey = InternalCodingKey.arrayIndex(arrayCount)
      return codingPath(appending: codingKey)
   }
}

extension SwiftValueToMessagePackValueEncoder {
   func store(_ value: EncodableMessagePackValue) {
      precondition(dictionary == nil && array == nil,
                   "Found existing top-level encoding container at coding path `\(codingPath)`.")

      finishInsertingInUseNestedEncoderIfNeeded()

      precondition(singleValue == nil,
                   "Found existing single value stored at coding path `\(codingPath)`.")

      singleValue = value
   }

   func nestedEncoder() -> SwiftValueToMessagePackValueEncoder {
      finishInsertingInUseNestedEncoderIfNeeded()

      return reuseNestedEncoder(for: nil,
                                transitioningTo: .pendingStorageAsSingleValue)
   }
}
