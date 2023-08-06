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

/// Represents the MessagePack timestamp extension type.
///
/// The timestamp is stored as the duration since `1970-01-01T00:00:00Z`.
///
/// Prefer to use this type instead of `Date` when preserving precision is important. This type has
/// nanosecond precision and uses integer values instead of floating-point values.
public struct MessagePackTimestamp {
   /// ``nanosecondsComponent`` must not exceed this value.
   public static let nanosecondsComponentMax: UInt32 = 999_999_999

   /// The seconds component.
   ///
   /// A negative value represents a time before `1970-01-01T00:00:00Z`.
   public var secondsComponent: Int64

   /// The nanoseconds component.
   ///
   /// A larger value is considered later in time than a smaller value—even if ``secondsComponent`` is negative.
   ///
   /// - Precondition: Must not exceed ``nanosecondsComponentMax``.
   public var nanosecondsComponent: UInt32 {
      didSet {
         validateNanosecondsComponent()
      }
   }

   /// Initializes the timestamp with its component values.
   ///
   /// - Precondition: `nanosecondsComponent` must not exceed ``nanosecondsComponentMax``.
   public init(secondsComponent: Int64,
               nanosecondsComponent: UInt32) {
      self.secondsComponent = secondsComponent
      self.nanosecondsComponent = nanosecondsComponent

      validateNanosecondsComponent()
   }

   func validateNanosecondsComponent() {
      precondition((0...Self.nanosecondsComponentMax).contains(nanosecondsComponent))
   }
}

extension MessagePackTimestamp: Hashable {
}

extension MessagePackTimestamp: Codable {
}

extension MessagePackTimestamp: Sendable {
}
