// MIT License
//
// Copyright © 2023–2024 Darren Mo.
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

/// An encoder to serialize Swift values to MessagePack bytes.
///
/// The encoder may be reused to serialize multiple values.
public struct MessagePackEncoder {
   /// A dictionary to provide contextual information to the nested values’ `encode(to:)` methods.
   public var userInfo = [CodingUserInfoKey: Any]()

   public init() {
   }

   /// Serializes a Swift value to MessagePack bytes.
   public func encode<T: Encodable>(_ value: T) throws -> Data {
      let swiftToMessagePackValueEncoder = SwiftValueToMessagePackValueEncoder(codingPath: [],
                                                                               userInfo: userInfo)

      var singleValueContainer = swiftToMessagePackValueEncoder.singleValueContainer()
      try singleValueContainer.encode(value)

      let messagePackValue = try swiftToMessagePackValueEncoder.encodableMessagePackValue

      var messageWriter = MessageWriter()
      try messagePackValue.encode(to: &messageWriter)
      return messageWriter.finish()
   }
}
