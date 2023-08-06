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

extension MessagePackTimestamp {
   public func validateForEncoding() throws {
      // We only need to validate that the nanoseconds component is less than 1 second.
      // That is enforced immediately after setting the `nanosecondsComponent` property,
      // so there is no need to add a similar check here.
   }

   public var encodedByteCount: UInt32 {
      if shouldUseTimestamp32Format {
         return 4
      } else if canUseTimestamp64Format {
         return 8
      } else {
         return 12
      }
   }

   private var shouldUseTimestamp32Format: Bool {
      return nanosecondsComponent == 0 && UInt32(exactly: secondsComponent) != nil
   }

   private var canUseTimestamp64Format: Bool {
      return (0..<(1<<34)).contains(secondsComponent) && (0..<(1<<30)).contains(nanosecondsComponent)
   }

   public func encode(to messageWriter: inout MessageWriter) {
      if shouldUseTimestamp32Format {
         encodeAsTimestamp32(to: &messageWriter)
      } else if canUseTimestamp64Format {
         encodeAsTimestamp64(to: &messageWriter)
      } else {
         encodeAsTimestamp96(to: &messageWriter)
      }
   }

   private func encodeAsTimestamp32(to messageWriter: inout MessageWriter) {
      precondition(nanosecondsComponent == 0)

      let secondsComponent = UInt32(secondsComponent)
      withUnsafeBytes(of: secondsComponent.bigEndian) {
         messageWriter.write($0)
      }
   }

   private func encodeAsTimestamp64(to messageWriter: inout MessageWriter) {
      let mergedValue = UInt64(nanosecondsComponent) << 34 + UInt64(secondsComponent)
      withUnsafeBytes(of: mergedValue.bigEndian) {
         messageWriter.write($0)
      }
   }

   private func encodeAsTimestamp96(to messageWriter: inout MessageWriter) {
      withUnsafeBytes(of: nanosecondsComponent.bigEndian) {
         messageWriter.write($0)
      }
      withUnsafeBytes(of: secondsComponent.bigEndian) {
         messageWriter.write($0)
      }
   }
}
