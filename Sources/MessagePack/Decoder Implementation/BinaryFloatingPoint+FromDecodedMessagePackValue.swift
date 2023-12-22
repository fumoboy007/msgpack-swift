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

extension BinaryFloatingPoint {
   init?(exactly messagePackValue: DecodedMessagePackValue) {
      switch messagePackValue {
      case .signedInteger(let value):
         // Some languages like JavaScript do not allow the developer to specify whether a number is a floating point
         // or integer value. A MessagePack encoder for such a language may choose to encode the number as an integer
         // when possible--even if the developer knows that the intended type of the value should be a floating point
         // type.
         //
         // Therefore, we should allow decoding integer values to floating point types for better interoperability
         // with applications written in such languages.
         guard let value = Self(exactly: value) else {
            return nil
         }
         self = value

      case .unsignedInteger(let value):
         // See above comment for the `signedInteger` case.
         guard let value = Self(exactly: value) else {
            return nil
         }
         self = value

      case .float32(let value):
         if let value = Self(exactly: value) {
            self = value
         } else if let value = value as? Self {
            self = value
         } else {
            return nil
         }

      case .float64(let value):
         if let value = Self(exactly: value) {
            self = value
         } else if let value = value as? Self {
            self = value
         } else {
            return nil
         }

      case .invalid,
            .nil,
            .boolean,
            .string,
            .binary,
            .array,
            .map,
            .applicationSpecificExtension,
            .unknownExtension,
            .messagePackTimestamp:
         return nil
      }
   }
}
