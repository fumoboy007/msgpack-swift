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

/// A decoder to deserialize Swift values from MessagePack bytes.
///
/// The decoder may be reused to deserialize multiple values.
public struct MessagePackDecoder {
   private var extensionTypeIDToMetatype: [Int8: DecodableAsMessagePackExtension.Type] = PredefinedExtensions.typeIDToMetatype
   /// An array of application-specific extension types.
   ///
   /// The decoder will attempt to deserialize application-specific extension payloads into one of these types.
   ///
   /// - Precondition: The extension type IDs must not overlap with each other nor with predefined type IDs.
   public var applicationSpecificExtensionTypes = [DecodableAsMessagePackExtension.Type]() {
      didSet {
         extensionTypeIDToMetatype = PredefinedExtensions.typeIDToMetatype

         for applicationSpecificMetatype in applicationSpecificExtensionTypes {
            let typeID = applicationSpecificMetatype.extensionTypeID
            precondition(!PredefinedExtensions.typeIDRange.contains(typeID),
                         "Application-specific extension has type \(typeID), which is reserved for predefined extensions.")

            precondition(extensionTypeIDToMetatype[typeID] == nil,
                         "Found duplicate extensions for type \(typeID).")
            extensionTypeIDToMetatype[typeID] = applicationSpecificMetatype
         }
      }
   }

   /// A dictionary to provide contextual information to the nested types’ `init(from:)` methods.
   public var userInfo = [CodingUserInfoKey: Any]()

   public init() {
   }

   /// Deserializes a Swift value from MessagePack bytes.
   public func decode<T: Decodable>(_ type: T.Type, from message: Data) throws -> T {
      let singleValueContainer = try singleValueContainer(for: message)

      return try singleValueContainer.decode(type)
   }

   /// Deserializes an optional Swift value from MessagePack bytes.
   public func decode<T: Decodable>(_ type: T?.Type, from message: Data) throws -> T? {
      let singleValueContainer = try singleValueContainer(for: message)

      if singleValueContainer.decodeNil() {
         return nil
      } else {
         return try singleValueContainer.decode(type)
      }
   }

   private func singleValueContainer(for message: Data) throws -> any SingleValueDecodingContainer {
      let messagePackValue = DecodedMessagePackValue(decoding: message,
                                                     extensionTypeIDToMetatype: extensionTypeIDToMetatype)

      let messagePackValueToSwiftValueDecoder = MessagePackValueToSwiftValueDecoder(messagePackValue: messagePackValue,
                                                                                    codingPath: [],
                                                                                    userInfo: userInfo)

      return try messagePackValueToSwiftValueDecoder.singleValueContainer()
   }
}
