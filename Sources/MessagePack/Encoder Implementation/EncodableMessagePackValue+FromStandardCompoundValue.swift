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
   init?<T>(standardCompoundValue value: T) {
      switch value {
      case let messagePackTimestamp as MessagePackTimestamp:
         self = .messagePackTimestamp(messagePackTimestamp)

      case let date as Date:
         // TODO: Support customizing the serialization approach.
         self = .messagePackTimestamp(MessagePackTimestamp(date))

      case let url as URL:
         self = .string(url.absoluteString.utf8)

      case let data as Data:
         self = .binary(data)

      case let decimal as Decimal:
         // TODO: Support customizing the serialization approach.
         self = .string(decimal.description.utf8)

      default:
         if let messagePackValue = Self(specializingCollection: value) {
            self = messagePackValue
         } else if let encodableAsExtension = value as? any EncodableAsMessagePackExtension {
            self = .applicationSpecificExtension(encodableAsExtension)
         } else {
            return nil
         }
      }
   }
}
