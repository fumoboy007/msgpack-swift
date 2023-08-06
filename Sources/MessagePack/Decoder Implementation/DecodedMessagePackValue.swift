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

import Foundation

// Some rare cases are marked as `indirect` to reduce memory usage for the common cases.
//
// An enum uses at least as much memory as its largest associated value. The rare cases
// that are marked as `indirect` have an existential container as their associated value.
// An existential container is 40 bytes whereas the next largest associated value is
// 24 bytes.
enum DecodedMessagePackValue {
   // This case is rare because developers inherently try to minimize errors.
   indirect case invalid(any Error)

   case `nil`

   case boolean(Bool)

   case signedInteger(Int64)
   case unsignedInteger(UInt64)

   case float32(Float32)
   case float64(Float64)

   case string(String)
   case binary(Data)

   case array(DecodedMessagePackArray)
   case map([MessagePackKey: DecodedMessagePackValue])

   // This case is rare because application-specific extensions are rare. Predefined
   // extensions (e.g. timestamp) are specialized below.
   indirect case applicationSpecificExtension(any DecodableAsMessagePackExtension)
   case unknownExtension(Int8, Data)

   // Specialized extensions
   case messagePackTimestamp(MessagePackTimestamp)
}
