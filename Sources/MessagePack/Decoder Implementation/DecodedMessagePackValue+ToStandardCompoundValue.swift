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

extension DecodedMessagePackValue {
   func toStandardCompoundValue<T: Decodable>(of type: T.Type) -> T? {
      switch type {
      case is MessagePackTimestamp.Type:
         return toMessagePackTimestamp()

      case is Date.Type:
         return toDate()

      case is URL.Type:
         return toURL()

      case is Data.Type:
         return toData()

      case is Decimal.Type:
         return toDecimal()

      case is DecodableAsMessagePackExtension.Type:
         return toExtension()

      default:
         if let collectionType = StandardSwiftCollectionType(reflecting: type),
            case .array(let elementType) = collectionType,
            case .array(let array) = self {
            return array.homogeneousArray(of: elementType) as? T
         } else {
            return nil
         }
      }
   }

   private func toMessagePackTimestamp<T: Decodable>() -> T? {
      guard case .messagePackTimestamp(let messagePackTimestamp) = self else {
         return nil
      }

      return messagePackTimestamp as? T
   }

   private func toDate<T: Decodable>() -> T? {
      // TODO: Support customizing the deserialization approach.
      switch self {
      case .string(let string):
         return Date(internetDateTime: string) as? T

      case .messagePackTimestamp(let messagePackTimestamp):
         return Date(messagePackTimestamp) as? T

      case .invalid,
            .nil,
            .boolean,
            .signedInteger,
            .unsignedInteger,
            .float32,
            .float64,
            .binary,
            .array,
            .map,
            .applicationSpecificExtension,
            .unknownExtension:
         return nil
      }
   }

   private func toURL<T: Decodable>() -> T? {
      guard case .string(let string) = self else {
         return nil
      }

      return URL(string: string) as? T
   }

   private func toData<T: Decodable>() -> T? {
      guard case .binary(let data) = self else {
         return nil
      }

      return data as? T
   }

   private func toDecimal<T: Decodable>() -> T? {
      switch self {
      case .signedInteger(let value):
         return Decimal(value) as? T

      case .unsignedInteger(let value):
         return Decimal(value) as? T

      case .float32(let value):
         guard !value.isInfinite else {
            return nil
         }
         return Decimal(Float64(value)) as? T

      case .float64(let value):
         guard !value.isInfinite else {
            return nil
         }
         return Decimal(value) as? T

      case .string(let string):
         return Decimal(string: string) as? T

      case .invalid,
            .nil,
            .boolean,
            .binary,
            .array,
            .map,
            .applicationSpecificExtension,
            .unknownExtension,
            .messagePackTimestamp:
         return nil
      }
   }

   private func toExtension<T: Decodable>() -> T? {
      guard case .applicationSpecificExtension(let decodableAsExtension) = self else {
         return nil
      }

      return decodableAsExtension as? T
   }
}
