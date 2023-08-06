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

// https://github.com/apple/swift-corelibs-foundation/issues/4703
#if !canImport(Darwin) && compiler(<5.9)
import Foundation

extension ISO8601DateFormatter.Options {
   static let withYear_nonDarwin = ISO8601DateFormatter.Options(rawValue: 1 << 0)

   static let withMonth_nonDarwin = ISO8601DateFormatter.Options(rawValue: 1 << 1)

   static let withWeekOfYear_nonDarwin = ISO8601DateFormatter.Options(rawValue: 1 << 2)

   static let withDay_nonDarwin = ISO8601DateFormatter.Options(rawValue: 1 << 4)

   static let withTime_nonDarwin = ISO8601DateFormatter.Options(rawValue: 1 << 5)

   static let withTimeZone_nonDarwin = ISO8601DateFormatter.Options(rawValue: 1 << 6)

   static let withSpaceBetweenDateAndTime_nonDarwin = ISO8601DateFormatter.Options(rawValue: 1 << 7)

   static let withDashSeparatorInDate_nonDarwin = ISO8601DateFormatter.Options(rawValue: 1 << 8)

   static let withColonSeparatorInTime_nonDarwin = ISO8601DateFormatter.Options(rawValue: 1 << 9)

   static let withColonSeparatorInTimeZone_nonDarwin = ISO8601DateFormatter.Options(rawValue: 1 << 10)

   static let withFractionalSeconds_nonDarwin = ISO8601DateFormatter.Options(rawValue: 1 << 11)

   static let withFullDate_nonDarwin = ISO8601DateFormatter.Options(rawValue: withYear_nonDarwin.rawValue + withMonth_nonDarwin.rawValue + withDay_nonDarwin.rawValue + withDashSeparatorInDate_nonDarwin.rawValue)

   static let withFullTime_nonDarwin = ISO8601DateFormatter.Options(rawValue: withTime_nonDarwin.rawValue + withTimeZone_nonDarwin.rawValue + withColonSeparatorInTime_nonDarwin.rawValue + withColonSeparatorInTimeZone_nonDarwin.rawValue)

   static let withInternetDateTime_nonDarwin = ISO8601DateFormatter.Options(rawValue: withFullDate_nonDarwin.rawValue + withFullTime_nonDarwin.rawValue)
}
#endif
