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

final class MessagePackValueToSwiftValueDecoder {
   private(set) var codingPath: [any CodingKey]

   let userInfo: [CodingUserInfoKey: Any]

   private var messagePackValue: DecodedMessagePackValue

   private var dictionary: [MessagePackKey: DecodedMessagePackValue]?
   private struct ArrayIterationState {
      var array: DecodedMessagePackArray
      var currentIndex: Int
   }
   private var arrayIterationState: ArrayIterationState?
   private var singleValue: DecodedMessagePackValue?

   private var reusableNestedDecoder: MessagePackValueToSwiftValueDecoder?

   init(messagePackValue: DecodedMessagePackValue,
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey: Any]) {
      self.messagePackValue = messagePackValue
      self.codingPath = codingPath
      self.userInfo = userInfo
   }

   private func reset(for newMessagePackValue: DecodedMessagePackValue,
                      replacingCodingKeyAtIndex codingPathIndexToReplace: Int,
                      with newCodingKey: (any CodingKey)?) {
      messagePackValue = newMessagePackValue

      if let newCodingKey {
         codingPath.replaceSubrange(codingPathIndexToReplace...,
                                    with: CollectionOfOne(newCodingKey))
      } else {
         codingPath.removeSubrange(codingPathIndexToReplace...)
      }

      dictionary = nil
      arrayIterationState = nil
      singleValue = nil
   }

   private func codingPath(appending codingKey: any CodingKey) -> [any CodingKey] {
      var codingPath = codingPath
      codingPath.append(codingKey)

      return codingPath
   }

   private func reuseNestedDecoder(toDecode nestedMessagePackValue: DecodedMessagePackValue,
                                   for codingKey: (any CodingKey)?) -> MessagePackValueToSwiftValueDecoder {
      if !isKnownUniquelyReferenced(&reusableNestedDecoder) {
         reusableNestedDecoder = nil
      }

      let nestedDecoder: MessagePackValueToSwiftValueDecoder
      if let reusableNestedDecoder {
         reusableNestedDecoder.reset(for: nestedMessagePackValue,
                                     replacingCodingKeyAtIndex: codingPath.count,
                                     with: codingKey)

         nestedDecoder = reusableNestedDecoder
      } else {
         var nestedCodingPath = codingPath
         if let codingKey {
            nestedCodingPath.append(codingKey)
         }

         nestedDecoder = Self(messagePackValue: nestedMessagePackValue,
                              codingPath: nestedCodingPath,
                              userInfo: userInfo)

         reusableNestedDecoder = nestedDecoder
      }

      return nestedDecoder
   }
}

extension MessagePackValueToSwiftValueDecoder: Decoder {
   func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
      precondition(arrayIterationState == nil && singleValue == nil,
                   "Found existing top-level decoding container at coding path `\(codingPath)`.")

      if dictionary == nil {
         try messagePackValue.ensureValid(at: codingPath)

         guard case .map(let dictionary) = messagePackValue else {
            throw DecodingError.typeMismatch(expectedType: [MessagePackKey: DecodedMessagePackValue].self,
                                             actual: messagePackValue,
                                             at: codingPath)
         }

         self.dictionary = dictionary
      }

      return KeyedDecodingContainer(KeyedMessagePackDecodingContainer(decoder: self))
   }

   func unkeyedContainer() throws -> UnkeyedDecodingContainer {
      precondition(dictionary == nil && singleValue == nil,
                   "Found existing top-level decoding container at coding path `\(codingPath)`.")

      if arrayIterationState == nil {
         try messagePackValue.ensureValid(at: codingPath)

         guard case .array(let array) = messagePackValue else {
            throw DecodingError.typeMismatch(expectedType: [DecodedMessagePackValue].self,
                                             actual: messagePackValue,
                                             at: codingPath)
         }

         arrayIterationState = ArrayIterationState(array: array,
                                                   currentIndex: 0)
      }

      return UnkeyedMessagePackDecodingContainer(decoder: self)
   }

   func singleValueContainer() throws -> SingleValueDecodingContainer {
      precondition(dictionary == nil && arrayIterationState == nil,
                   "Found existing top-level decoding container at coding path `\(codingPath)`.")

      if singleValue == nil {
         try messagePackValue.ensureValid(at: codingPath)

         singleValue = messagePackValue
      }

      return SingleValueMessagePackDecodingContainer(decoder: self)
   }
}

extension MessagePackValueToSwiftValueDecoder {
   func allKeys<Key: CodingKey>(of type: Key.Type) -> [Key] {
      return dictionary!.keys.compactMap { messagePackKey in
         switch messagePackKey {
         case .string(let key):
            return Key(stringValue: key)

         case .int(let key):
            return Key(intValue: key)
         }
      }
   }

   func contains<Key: CodingKey>(_ codingKey: Key) -> Bool {
      let key = MessagePackKey(codingKey)

      return dictionary![key] != nil
   }

   func isValueNil<Key: CodingKey>(for codingKey: Key) throws -> Bool {
      let messagePackValue = try messagePackValue(for: codingKey)

      if case .nil = messagePackValue {
         return true
      } else {
         return false
      }
   }

   func simpleValue<Key, Value>(of type: Value.Type, for codingKey: Key) throws -> Value where Key: CodingKey, Value: SimpleDecodable {
      let messagePackValue = try messagePackValue(for: codingKey)

      guard let value = type.init(exactly: messagePackValue) else {
         throw DecodingError.typeMismatch(expectedType: type,
                                          actual: messagePackValue,
                                          at: codingPath(appending: codingKey))
      }

      return value
   }

   func compoundValue<Key, Value>(of type: Value.Type, for codingKey: Key) throws -> Value where Key: CodingKey, Value: Decodable {
      let messagePackValue = try messagePackValue(for: codingKey)

      if let value = messagePackValue.toStandardCompoundValue(of: type) {
         return value
      }

      let nestedDecoder = reuseNestedDecoder(toDecode: messagePackValue, for: codingKey)
      return try type.init(from: nestedDecoder)
   }

   func nestedDecoder<Key: CodingKey>(for codingKey: Key) throws -> MessagePackValueToSwiftValueDecoder {
      let messagePackValue = try messagePackValue(for: codingKey)

      return reuseNestedDecoder(toDecode: messagePackValue, for: codingKey)
   }

   private func messagePackValue<Key: CodingKey>(for codingKey: Key) throws -> DecodedMessagePackValue {
      let key = MessagePackKey(codingKey)

      guard let messagePackValue = dictionary![key] else {
         let context = DecodingError.Context(codingPath: codingPath(appending: codingKey),
                                             debugDescription: "Key not found.")
         throw DecodingError.keyNotFound(codingKey, context)
      }

      try messagePackValue.ensureValid(at: codingPath(appending: codingKey))

      return messagePackValue
   }
}

extension MessagePackValueToSwiftValueDecoder {
   var arrayCount: Int {
      return arrayIterationState!.array.count
   }

   var currentArrayIndex: Int {
      return arrayIterationState!.currentIndex
   }

   func removeNextIfNil() throws -> Bool {
      let messagePackValue = try nextMessagePackValue(for: Never.self)

      if case .nil = messagePackValue {
         incrementCurrentArrayIndex()
         return true
      } else {
         return false
      }
   }

   func removeNextAsSimpleValue<T: SimpleDecodable>(of type: T.Type) throws -> T {
      let messagePackValue = try nextMessagePackValue(for: type)

      guard let value = type.init(exactly: messagePackValue) else {
         throw DecodingError.typeMismatch(expectedType: type,
                                          actual: messagePackValue,
                                          at: codingPathForCurrentArrayIndex)
      }

      incrementCurrentArrayIndex()
      return value
   }

   func removeNextAsCompoundValue<T: Decodable>(of type: T.Type) throws -> T {
      let messagePackValue = try nextMessagePackValue(for: type)

      if let value = messagePackValue.toStandardCompoundValue(of: type) {
         incrementCurrentArrayIndex()
         return value
      }

      let nestedDecoder = reuseNestedDecoder(toDecode: messagePackValue, for: codingKeyForCurrentArrayIndex)
      let value = try type.init(from: nestedDecoder)

      incrementCurrentArrayIndex()
      return value
   }

   func removeNextAsNestedDecoder() throws -> MessagePackValueToSwiftValueDecoder {
      let messagePackValue = try nextMessagePackValue(for: Self.self)

      let nestedDecoder = reuseNestedDecoder(toDecode: messagePackValue, for: codingKeyForCurrentArrayIndex)

      incrementCurrentArrayIndex()
      return nestedDecoder
   }

   private func nextMessagePackValue<T>(for type: T.Type) throws -> DecodedMessagePackValue {
      let array = arrayIterationState!.array

      let currentIndex = arrayIterationState!.currentIndex
      guard currentIndex < array.count else {
         let context = DecodingError.Context(codingPath: codingPathForCurrentArrayIndex,
                                             debugDescription: "No remaining values in array.")
         throw DecodingError.valueNotFound(type, context)
      }

      let messagePackValue = array[currentIndex]
      try messagePackValue.ensureValid(at: codingPathForCurrentArrayIndex)

      return messagePackValue
   }

   private var codingPathForCurrentArrayIndex: [any CodingKey] {
      return codingPath(appending: codingKeyForCurrentArrayIndex)
   }

   private var codingKeyForCurrentArrayIndex: any CodingKey {
      return InternalCodingKey.arrayIndex(arrayIterationState!.currentIndex)
   }

   private func incrementCurrentArrayIndex() {
      arrayIterationState!.currentIndex += 1
   }
}

extension MessagePackValueToSwiftValueDecoder {
   func isValueNil() -> Bool {
      let messagePackValue = singleValue!

      if case .nil = messagePackValue {
         return true
      } else {
         return false
      }
   }

   func simpleValue<T: SimpleDecodable>(of type: T.Type) throws -> T {
      let messagePackValue = singleValue!

      guard let value = type.init(exactly: messagePackValue) else {
         throw DecodingError.typeMismatch(expectedType: type,
                                          actual: messagePackValue,
                                          at: codingPath)
      }

      return value
   }

   func compoundValue<T: Decodable>(of type: T.Type) throws -> T {
      let messagePackValue = singleValue!

      if let value = messagePackValue.toStandardCompoundValue(of: type) {
         return value
      }

      let nestedDecoder = reuseNestedDecoder(toDecode: messagePackValue, for: nil)
      return try type.init(from: nestedDecoder)
   }
}
