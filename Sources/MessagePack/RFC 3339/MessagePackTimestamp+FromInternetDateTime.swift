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
import RegexBuilder

extension MessagePackTimestamp {
   /// Initializes the timestamp from a string that follows the RFC 3339 Internet date/time format.
   ///
   /// Example string: `2021-02-22T15:51:44.208Z`
   ///
   /// - Remark: The equivalent `Date`/`ISO8601DateFormatter` methods only have millisecond precision.
   /// This method has nanosecond precision.
   public init?(internetDateTime string: String) {
      var hasFractionalSeconds = false
      guard let date = Date(internetDateTime: string, hasFractionalSeconds: &hasFractionalSeconds) else {
         return nil
      }

      self.init(date)

      // Extract fractional seconds manually because `ISO8601DateFormatter` only has millisecond precision.
      if hasFractionalSeconds {
         self.nanosecondsComponent = Self.nanosecondsComponent(fromInternetDateTime: string)
         validateNanosecondsComponent()
      }
   }

   private static func nanosecondsComponent(fromInternetDateTime string: String) -> UInt32 {
      let nanosecondsDigitCount = 9
      enum NanosecondsRoundingOperation {
         case none
         case upIfNotEven
         case up
      }

      let fractionalSecondsRegex = Regex {
         "."

         TryCapture {
            Repeat(count: nanosecondsDigitCount) {
               Optionally(.digit)
            }
         } transform: { (fractionalSecondsString) -> UInt32 in
            var nanosecondsComponent = UInt32(fractionalSecondsString)!
            for _ in fractionalSecondsString.count..<9 {
               nanosecondsComponent *= 10
            }
            return nanosecondsComponent
         }

         TryCapture {
            ZeroOrMore(.digit)
         } transform: { (nanosecondsFractionalPart) -> NanosecondsRoundingOperation in
            guard !nanosecondsFractionalPart.isEmpty else {
               return .none
            }

            let firstDigit = nanosecondsFractionalPart.first!
            switch firstDigit {
            case "0", "1", "2", "3", "4":
               return .none

            case "6", "7", "8", "9":
               return .up

            case "5":
               for digit in nanosecondsFractionalPart.dropFirst() {
                  switch digit {
                  case "0":
                     continue

                  default:
                     return .up
                  }
               }
               return .upIfNotEven

            default:
               preconditionFailure("Expected digit but found `\(firstDigit)`.")
            }
         }
      }

      let matches = string.matches(of: fractionalSecondsRegex)
      precondition(matches.count == 1)
      let match = matches[0]

      var (_, nanosecondsComponent, roundingOperation) = match.output

      switch roundingOperation {
      case .none:
         break

      case .upIfNotEven:
         if !nanosecondsComponent.isMultiple(of: 2) {
            nanosecondsComponent += 1
         }

      case .up:
         nanosecondsComponent += 1
      }

      return nanosecondsComponent
   }
}
