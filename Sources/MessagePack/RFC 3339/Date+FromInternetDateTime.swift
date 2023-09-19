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

extension Date {
   private static let formatterWithoutFractionalSeconds: ISO8601DateFormatter = {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [
         .withInternetDateTime
      ]
      return formatter
   }()

   private static let formatterWithFractionalSeconds: ISO8601DateFormatter = {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [
         .withInternetDateTime,
         .withFractionalSeconds
      ]
      return formatter
   }()

   init?(internetDateTime string: String) {
      var hasFractionalSeconds = false
      self.init(internetDateTime: string, hasFractionalSeconds: &hasFractionalSeconds)
   }

   init?(internetDateTime string: String, hasFractionalSeconds: inout Bool) {
      hasFractionalSeconds = string.reversed().contains(".")

      let formatter: ISO8601DateFormatter
      if hasFractionalSeconds {
         formatter = Self.formatterWithFractionalSeconds
      } else {
         formatter = Self.formatterWithoutFractionalSeconds
      }

      guard let date = formatter.date(from: string) else {
         return nil
      }
      self = date
   }
}
