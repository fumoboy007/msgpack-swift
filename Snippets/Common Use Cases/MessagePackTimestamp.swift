// The ``MessagePackTimestamp`` structure represents the MessagePack timestamp extension type.

// snippet.hide

import Foundation
import MessagePack

// snippet.show

// snippet.codable

struct MyMessage: Codable {
   let myTimestamp: MessagePackTimestamp
}

// snippet.init-with-components

var timestamp = MessagePackTimestamp(secondsComponent: 1719102009,
                                     nanosecondsComponent: 781666897)

// snippet.init-with-rfc3339

timestamp = MessagePackTimestamp(internetDateTime: "2023-09-10T19:19:59.123456789-07:00")!

// snippet.init-with-date

timestamp = MessagePackTimestamp(Date.now)

// snippet.date-from-timestamp

let date = Date(timestamp)
