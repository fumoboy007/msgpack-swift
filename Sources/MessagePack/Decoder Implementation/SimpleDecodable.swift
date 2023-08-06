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

protocol SimpleDecodable {
   init?(exactly messagePackValue: DecodedMessagePackValue)
}

extension Bool: SimpleDecodable {
   init?(exactly messagePackValue: DecodedMessagePackValue) {
      if case .boolean(let value) = messagePackValue {
         self = value
      } else {
         return nil
      }
   }
}

extension String: SimpleDecodable {
   init?(exactly messagePackValue: DecodedMessagePackValue) {
      if case .string(let value) = messagePackValue {
         self = value
      } else {
         return nil
      }
   }
}

extension Float64: SimpleDecodable {
}

extension Float32: SimpleDecodable {
}

extension Int: SimpleDecodable {
}

extension Int8: SimpleDecodable {
}

extension Int16: SimpleDecodable {
}

extension Int32: SimpleDecodable {
}

extension Int64: SimpleDecodable {
}

extension UInt: SimpleDecodable {
}

extension UInt8: SimpleDecodable {
}

extension UInt16: SimpleDecodable {
}

extension UInt32: SimpleDecodable {
}

extension UInt64: SimpleDecodable {
}
