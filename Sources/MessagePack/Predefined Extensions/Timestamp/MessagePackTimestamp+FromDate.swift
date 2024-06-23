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

extension MessagePackTimestamp {
   /// Initializes the timestamp from a `Date` instance.
   ///
   /// The nanoseconds component will be rounded using Swift’s default rounding rule.
   ///
   /// - SeeAlso: ``Foundation/Date/init(_:)``
   public init(_ date: Date) {
      let timeIntervalSince1970 = date.timeIntervalSince1970

      var secondsComponent = Int64(timeIntervalSince1970.rounded(.down))

      var nanosecondsComponentFloatingPoint = timeIntervalSince1970.truncatingRemainder(dividingBy: 1)
      if nanosecondsComponentFloatingPoint < 0 {
         nanosecondsComponentFloatingPoint += 1
      }
      nanosecondsComponentFloatingPoint *= 1E9
      nanosecondsComponentFloatingPoint.round()

      var nanosecondsComponent = UInt32(nanosecondsComponentFloatingPoint)
      if nanosecondsComponent > Self.nanosecondsComponentMax {
         secondsComponent += 1
         nanosecondsComponent -= 1_000_000_000
      }

      self.init(secondsComponent: secondsComponent,
                nanosecondsComponent: nanosecondsComponent)
   }
}
