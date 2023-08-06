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
import XCTest

enum RuntimeEnvironment {
   private static var isProgramOptimized: Bool {
      #if DEBUG
      return false
      #else
      return true
      #endif
   }

   static func skipTestIfProgramNotOptimized() throws {
      try XCTSkipUnless(isProgramOptimized,
                        "The test requires the program to have been built with optimizations enabled.")
   }

   static func skipTestIfAvailableMemoryLessThan(gib requiredMemoryInGiB: Int) throws {
      let availableMemory = ProcessInfo.processInfo.physicalMemory
      try XCTSkipIf(availableMemory < requiredMemoryInGiB * 1024 * 1024 * 1024,
                    "The test requires at least \(requiredMemoryInGiB) GiB of memory but the host only has \(Double(availableMemory) / 1024 / 1024 / 1024) GiB.")
   }
}
