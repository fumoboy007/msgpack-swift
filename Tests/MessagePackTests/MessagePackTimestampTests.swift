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

import MessagePack

import XCTest

class MessagePackTimestampTests: XCTestCase {
   func testComparison_lessThan() {
      let lhs = MessagePackTimestamp(secondsComponent: 0,
                                     nanosecondsComponent: 1)
      let rhs = MessagePackTimestamp(secondsComponent: 1,
                                     nanosecondsComponent: 0)

      XCTAssertLessThan(lhs, rhs)
   }

   func testComparison_lessThan_requiresNanosecondsComparison() {
      let lhs = MessagePackTimestamp(secondsComponent: 0,
                                     nanosecondsComponent: 0)
      let rhs = MessagePackTimestamp(secondsComponent: 0,
                                     nanosecondsComponent: 1)

      XCTAssertLessThan(lhs, rhs)
   }

   func testComparison_greaterThan() {
      let lhs = MessagePackTimestamp(secondsComponent: 1,
                                     nanosecondsComponent: 0)
      let rhs = MessagePackTimestamp(secondsComponent: 0,
                                     nanosecondsComponent: 1)

      XCTAssertGreaterThan(lhs, rhs)
   }

   func testComparison_greaterThan_requiresNanosecondsComparison() {
      let lhs = MessagePackTimestamp(secondsComponent: 0,
                                     nanosecondsComponent: 1)
      let rhs = MessagePackTimestamp(secondsComponent: 0,
                                     nanosecondsComponent: 0)

      XCTAssertGreaterThan(lhs, rhs)
   }

   func testComparison_equal() {
      let lhs = MessagePackTimestamp(secondsComponent: 0,
                                     nanosecondsComponent: 1)
      let rhs = MessagePackTimestamp(secondsComponent: 0,
                                     nanosecondsComponent: 1)

      XCTAssertLessThanOrEqual(lhs, rhs)
      XCTAssertGreaterThanOrEqual(lhs, rhs)
   }

   func testAdvancedByDuration() {
      let original = MessagePackTimestamp(secondsComponent: 0,
                                          nanosecondsComponent: 0)
      let durationToAdvance: Duration = .seconds(1) + .nanoseconds(-1)

      let advanced = original.advanced(by: durationToAdvance)

      let expected = MessagePackTimestamp(secondsComponent: 0,
                                          nanosecondsComponent: 999_999_999)
      XCTAssertEqual(advanced, expected)
   }

   func testAdvancedByDuration_nanosecondsRounding_roundedDown() {
      let original = MessagePackTimestamp(secondsComponent: 0,
                                          nanosecondsComponent: 0)
      let durationToAdvance = Duration(secondsComponent: 0,
                                       attosecondsComponent: 499_999_999)

      let advanced = original.advanced(by: durationToAdvance)

      let expected = MessagePackTimestamp(secondsComponent: 0,
                                          nanosecondsComponent: 0)
      XCTAssertEqual(advanced, expected)
   }

   func testAdvancedByDuration_nanosecondsRounding_roundedUp() {
      let original = MessagePackTimestamp(secondsComponent: 0,
                                          nanosecondsComponent: 0)
      let durationToAdvance = Duration(secondsComponent: 0,
                                       attosecondsComponent: 500_000_001)

      let advanced = original.advanced(by: durationToAdvance)

      let expected = MessagePackTimestamp(secondsComponent: 0,
                                          nanosecondsComponent: 1)
      XCTAssertEqual(advanced, expected)
   }

   func testAdvancedByDuration_nanosecondsRounding_roundedDownDueToEvenNumber() {
      let original = MessagePackTimestamp(secondsComponent: 0,
                                          nanosecondsComponent: 0)
      let durationToAdvance = Duration(secondsComponent: 0,
                                       attosecondsComponent: 500_000_000)

      let advanced = original.advanced(by: durationToAdvance)

      let expected = MessagePackTimestamp(secondsComponent: 0,
                                          nanosecondsComponent: 0)
      XCTAssertEqual(advanced, expected)
   }

   func testAdvancedByDuration_nanosecondsRounding_roundedUpDueToOddNumber() {
      let original = MessagePackTimestamp(secondsComponent: 0,
                                          nanosecondsComponent: 0)
      let durationToAdvance = Duration(secondsComponent: 0,
                                       attosecondsComponent: 1_500_000_000)

      let advanced = original.advanced(by: durationToAdvance)

      let expected = MessagePackTimestamp(secondsComponent: 0,
                                          nanosecondsComponent: 2)
      XCTAssertEqual(advanced, expected)
   }

   func testAdvancedByDuration_nanosecondsComponentOverflows() {
      let original = MessagePackTimestamp(secondsComponent: 0,
                                          nanosecondsComponent: 2)
      let durationToAdvance: Duration = .seconds(1) + .nanoseconds(999_999_999)

      let advanced = original.advanced(by: durationToAdvance)

      let expected = MessagePackTimestamp(secondsComponent: 2,
                                          nanosecondsComponent: 1)
      XCTAssertEqual(advanced, expected)
   }

   func testDurationToOther() {
      let timestamp1 = MessagePackTimestamp(secondsComponent: 0,
                                            nanosecondsComponent: 1)
      let timestamp2 = MessagePackTimestamp(secondsComponent: 1,
                                            nanosecondsComponent: 0)

      let duration = timestamp1.duration(to: timestamp2)

      XCTAssertEqual(duration, .nanoseconds(999_999_999))
   }

   func testInitFromDate_positiveSecondsComponent() {
      let date = Date(timeIntervalSince1970: 1.5)

      let timestamp = MessagePackTimestamp(date)

      let expectedTimestamp = MessagePackTimestamp(secondsComponent: 1,
                                                   nanosecondsComponent: 500000000)
      XCTAssertEqual(timestamp, expectedTimestamp)
   }

   func testInitFromDate_negativeSecondsComponent() {
      let date = Date(timeIntervalSince1970: -1.5)

      let timestamp = MessagePackTimestamp(date)

      let expectedTimestamp = MessagePackTimestamp(secondsComponent: -2,
                                                   nanosecondsComponent: 500000000)
      XCTAssertEqual(timestamp, expectedTimestamp)
   }

   func testInitFromDate_nanosecondsRoundedUpToSecond() {
      let date = Date(timeIntervalSince1970: 0.9999999996)

      let timestamp = MessagePackTimestamp(date)

      let expectedTimestamp = MessagePackTimestamp(secondsComponent: 1,
                                                   nanosecondsComponent: 0)
      XCTAssertEqual(timestamp, expectedTimestamp)
   }

   func testToDate_positiveSecondsComponent() {
      let timestamp = MessagePackTimestamp(secondsComponent: 1,
                                           nanosecondsComponent: 500000000)

      let date = Date(timestamp)

      let expectedDate = Date(timeIntervalSince1970: 1.5)
      XCTAssertEqual(date, expectedDate)
   }

   func testToDate_negativeSecondsComponent() {
      let timestamp = MessagePackTimestamp(secondsComponent: -2,
                                           nanosecondsComponent: 500000000)

      let date = Date(timestamp)

      let expectedDate = Date(timeIntervalSince1970: -1.5)
      XCTAssertEqual(date, expectedDate)
   }

   func testInitFromInternetDateTime_noFractionalSeconds() throws {
      let string = "1970-01-01T00:00:00Z"

      let timestamp = try XCTUnwrap(MessagePackTimestamp(internetDateTime: string))

      let expectedTimestamp = MessagePackTimestamp(secondsComponent: 0,
                                                   nanosecondsComponent: 0)
      XCTAssertEqual(timestamp, expectedTimestamp)
   }

   func testInitFromInternetDateTime_fractionalSeconds_fewerThanNineDigits() throws {
      let string = "1970-01-01T00:00:00.1Z"

      let timestamp = try XCTUnwrap(MessagePackTimestamp(internetDateTime: string))

      let expectedTimestamp = MessagePackTimestamp(secondsComponent: 0,
                                                   nanosecondsComponent: 100_000_000)
      XCTAssertEqual(timestamp, expectedTimestamp)
   }

   func testInitFromInternetDateTime_fractionalSeconds_nineDigits() throws {
      let string = "1970-01-01T00:00:00.123456789Z"

      let timestamp = try XCTUnwrap(MessagePackTimestamp(internetDateTime: string))

      let expectedTimestamp = MessagePackTimestamp(secondsComponent: 0,
                                                   nanosecondsComponent: 123_456_789)
      XCTAssertEqual(timestamp, expectedTimestamp)
   }

   func testInitFromInternetDateTime_fractionalSeconds_moreThanNineDigits_roundedDown() throws {
      let string = "1970-01-01T00:00:00.1234567891Z"

      let timestamp = try XCTUnwrap(MessagePackTimestamp(internetDateTime: string))

      let expectedTimestamp = MessagePackTimestamp(secondsComponent: 0,
                                                   nanosecondsComponent: 123_456_789)
      XCTAssertEqual(timestamp, expectedTimestamp)
   }

   func testInitFromInternetDateTime_fractionalSeconds_moreThanNineDigits_roundedUp() throws {
      let string = "1970-01-01T00:00:00.1234567899Z"

      let timestamp = try XCTUnwrap(MessagePackTimestamp(internetDateTime: string))

      let expectedTimestamp = MessagePackTimestamp(secondsComponent: 0,
                                                   nanosecondsComponent: 123_456_790)
      XCTAssertEqual(timestamp, expectedTimestamp)
   }

   func testInitFromInternetDateTime_fractionalSeconds_moreThanNineDigits_roundedHalfEven() throws {
      let string = "1970-01-01T00:00:00.1234567895Z"

      let timestamp = try XCTUnwrap(MessagePackTimestamp(internetDateTime: string))

      let expectedTimestamp = MessagePackTimestamp(secondsComponent: 0,
                                                   nanosecondsComponent: 123_456_790)
      XCTAssertEqual(timestamp, expectedTimestamp)
   }

   func testInitFromInternetDateTime_fractionalSeconds_leftPaddedWithZeroes() throws {
      let string = "1970-01-01T00:00:00.01Z"

      let timestamp = try XCTUnwrap(MessagePackTimestamp(internetDateTime: string))

      let expectedTimestamp = MessagePackTimestamp(secondsComponent: 0,
                                                   nanosecondsComponent: 10_000_000)
      XCTAssertEqual(timestamp, expectedTimestamp)
   }

   func testInitFromInternetDateTime_negativeSecondsComponent() throws {
      let string = "1969-12-31T23:59:59.1Z"

      let timestamp = try XCTUnwrap(MessagePackTimestamp(internetDateTime: string))

      let expectedTimestamp = MessagePackTimestamp(secondsComponent: -1,
                                                   nanosecondsComponent: 100000000)
      XCTAssertEqual(timestamp, expectedTimestamp)
   }

   func testInitFromInternetDateTime_invalid() {
      let string = "1970-01-01T00:00:00.1.1Z"

      XCTAssertNil(MessagePackTimestamp(internetDateTime: string))
   }
}
