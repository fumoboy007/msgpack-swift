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

extension MessagePackTimestamp: InstantProtocol {
   public static func <(lhs: MessagePackTimestamp, rhs: MessagePackTimestamp) -> Bool {
      if lhs.secondsComponent < rhs.secondsComponent {
         return true
      } else if lhs.secondsComponent > rhs.secondsComponent {
         return false
      } else {
         return lhs.nanosecondsComponent < rhs.nanosecondsComponent
      }
   }

   public func advanced(by duration: Duration) -> MessagePackTimestamp {
      let (secondsToAdd, attosecondsToAdd) = duration.components
      precondition(attosecondsToAdd >= 0)

      var secondsComponent = secondsComponent + secondsToAdd

      var (nanosecondsToAdd, remainder) = attosecondsToAdd.quotientAndRemainder(dividingBy: 1_000_000_000)
      if remainder > 500_000_000 || (remainder == 500_000_000 && !nanosecondsToAdd.isMultiple(of: 2)) {
         nanosecondsToAdd += 1
      }

      var nanosecondsComponent = Int64(nanosecondsComponent) + nanosecondsToAdd
      if nanosecondsComponent > Self.nanosecondsComponentMax {
         secondsComponent += 1
         nanosecondsComponent -= 1_000_000_000
      }

      return MessagePackTimestamp(secondsComponent: secondsComponent,
                                  nanosecondsComponent: UInt32(nanosecondsComponent))
   }

   public func duration(to other: MessagePackTimestamp) -> Duration {
      let secondsToOther = other.secondsComponent - self.secondsComponent
      let nanosecondsToOther = Int64(other.nanosecondsComponent) - Int64(self.nanosecondsComponent)

      return .seconds(secondsToOther) + .nanoseconds(nanosecondsToOther)
   }
}
