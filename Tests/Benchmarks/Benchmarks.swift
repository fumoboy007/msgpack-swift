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

import Logging
import MessagePacker
import SwiftMsgpack
import XCTest

final class Benchmarks: XCTestCase {
   static let logger = Logger(label: String(reflecting: Benchmarks.self))

   static let iterationCount = 10_000

   func testAlpacaTradeEvent() async throws {
      let alpacaTradeEvent = AlpacaTradeEvent.fake
      let alpacaTradeEventForSwiftMsgpack = AlpacaTradeEventForSwiftMsgpack(alpacaTradeEvent)
      let alpacaTradeEventForMessagePacker = AlpacaTradeEventForMessagePacker(alpacaTradeEvent)

      try runBenchmark(blockUsingCurrentLibrary: {
         try Self.encodeAndDecodeUsingCurrentLibrary(alpacaTradeEvent)
      }, otherLibraryNameToBlockMap: [
         "nnabeyang/swift-msgpack": {
            try Self.encodeAndDecodeUsingSwiftMsgpackLibrary(alpacaTradeEventForSwiftMsgpack)
         },
         "hirotakan/MessagePacker": {
            try Self.encodeAndDecodeUsingMessagePackerLibrary(alpacaTradeEventForMessagePacker)
         }
      ])
   }

   func testAlpacaQuoteEvent() async throws {
      let alpacaQuoteEvent = AlpacaQuoteEvent.fake
      let alpacaQuoteEventForSwiftMsgpack = AlpacaQuoteEventForSwiftMsgpack(alpacaQuoteEvent)
      let alpacaQuoteEventForMessagePacker = AlpacaQuoteEventForMessagePacker(alpacaQuoteEvent)

      try runBenchmark(blockUsingCurrentLibrary: {
         try Self.encodeAndDecodeUsingCurrentLibrary(alpacaQuoteEvent)
      }, otherLibraryNameToBlockMap: [
         "nnabeyang/swift-msgpack": {
            try Self.encodeAndDecodeUsingSwiftMsgpackLibrary(alpacaQuoteEventForSwiftMsgpack)
         },
         "hirotakan/MessagePacker": {
            try Self.encodeAndDecodeUsingMessagePackerLibrary(alpacaQuoteEventForMessagePacker)
         }
      ])
   }

   private static func encodeAndDecodeUsingCurrentLibrary<T: Codable>(_ value: T) throws {
      let encoder = MessagePack.MessagePackEncoder()
      let message = try encoder.encode(value)

      let decoder = MessagePack.MessagePackDecoder()
      _ = try decoder.decode(T.self, from: message)
   }

   private static func encodeAndDecodeUsingSwiftMsgpackLibrary<T: Codable>(_ value: T) throws {
      let encoder = MsgPackEncoder()
      let message = try encoder.encode(value)

      let decoder = MsgPackDecoder()
      _ = try decoder.decode(T.self, from: message)
   }

   private static func encodeAndDecodeUsingMessagePackerLibrary<T: Codable>(_ value: T) throws {
      let encoder = MessagePacker.MessagePackEncoder()
      let message = try encoder.encode(value)

      let decoder = MessagePacker.MessagePackDecoder()
      _ = try decoder.decode(T.self, from: message)
   }

   private func runBenchmark(blockUsingCurrentLibrary: () throws -> Void,
                             otherLibraryNameToBlockMap: [String: () throws -> Void]) throws {
      let clock = SuspendingClock()

      let currentLibraryDuration = try clock.measure(iterationCount: Self.iterationCount, blockUsingCurrentLibrary)
      Self.logger.info("Latency: \(currentLibraryDuration)")

      for (otherLibraryName, block) in otherLibraryNameToBlockMap {
         let otherLibraryDuration = try clock.measure(iterationCount: Self.iterationCount, block)
         Self.logger.info("`\(otherLibraryName)` Latency: \(otherLibraryDuration)")

         XCTAssertLessThanOrEqual(currentLibraryDuration, otherLibraryDuration)

         if currentLibraryDuration <= otherLibraryDuration {
            let latencyMultiplier = otherLibraryDuration / currentLibraryDuration

            let latencyMultiplierString: String
            // https://github.com/apple/swift-corelibs-foundation/issues/4618#issuecomment-1200383741
            #if canImport(Darwin)
            latencyMultiplierString = latencyMultiplier.formatted(.number.precision(.fractionLength(1)))
            #else
            latencyMultiplierString = String(format: "%.1f", latencyMultiplier)
            #endif

            Self.logger.info("This library is \(latencyMultiplierString)× faster than the `\(otherLibraryName)` library.")
         }
      }
   }
}
