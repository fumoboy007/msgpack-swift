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

import SwiftMsgpack

struct AlpacaQuoteEventForSwiftMsgpack {
   var eventType: String

   var symbol: String

   var timestamp: MsgPackTimestamp

   var tapeID: String

   var askExchangeID: String
   var askPrice: Double
   var askSizeInRoundLots: Int

   var bidExchangeID: String
   var bidPrice: Double
   var bidSizeInRoundLots: Int

   var conditions: [String]
}

extension AlpacaQuoteEventForSwiftMsgpack {
   init(_ alpacaQuoteEvent: AlpacaQuoteEvent) {
      self.init(eventType: alpacaQuoteEvent.eventType,
                symbol: alpacaQuoteEvent.symbol,
                timestamp: MsgPackTimestamp(alpacaQuoteEvent.timestamp),
                tapeID: alpacaQuoteEvent.tapeID,
                askExchangeID: alpacaQuoteEvent.askExchangeID,
                askPrice: alpacaQuoteEvent.askPrice,
                askSizeInRoundLots: alpacaQuoteEvent.askSizeInRoundLots,
                bidExchangeID: alpacaQuoteEvent.bidExchangeID,
                bidPrice: alpacaQuoteEvent.bidPrice,
                bidSizeInRoundLots: alpacaQuoteEvent.bidSizeInRoundLots,
                conditions: alpacaQuoteEvent.conditions)
   }
}

extension AlpacaQuoteEventForSwiftMsgpack: Codable {
   enum CodingKeys: String, CodingKey {
      case eventType = "T"

      case symbol = "S"

      case timestamp = "t"

      case tapeID = "z"

      case askExchangeID = "ax"
      case askPrice = "ap"
      case askSizeInRoundLots = "as"

      case bidExchangeID = "bx"
      case bidPrice = "bp"
      case bidSizeInRoundLots = "bs"

      case conditions = "c"
   }
}
