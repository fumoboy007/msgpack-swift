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

import MessagePacker

struct AlpacaTradeEventForMessagePacker {
   var eventType: String

   var symbol: String

   var timestamp: MessagePackTimestamp

   var tapeID: String
   var exchangeID: String
   var relativeTradeID: Int

   var price: Double
   var quantity: Int

   var conditions: [String]
}

extension AlpacaTradeEventForMessagePacker {
   init(_ alpacaTradeEvent: AlpacaTradeEvent) {
      self.init(eventType: alpacaTradeEvent.eventType,
                symbol: alpacaTradeEvent.symbol,
                timestamp: MessagePackTimestamp(alpacaTradeEvent.timestamp),
                tapeID: alpacaTradeEvent.tapeID,
                exchangeID: alpacaTradeEvent.exchangeID,
                relativeTradeID: alpacaTradeEvent.relativeTradeID,
                price: alpacaTradeEvent.price,
                quantity: alpacaTradeEvent.quantity,
                conditions: alpacaTradeEvent.conditions)
   }
}

extension AlpacaTradeEventForMessagePacker: Codable {
   enum CodingKeys: String, CodingKey {
      case eventType = "T"

      case symbol = "S"

      case timestamp = "t"

      case tapeID = "z"
      case exchangeID = "x"
      case relativeTradeID = "i"

      case price = "p"
      case quantity = "s"

      case conditions = "c"
   }
}
