import App
import Foundation

if
    let param = ProcessInfo.processInfo.environment["SLEEP_LENGTH"],
    let duration = UInt32(param), duration > 0
{
    sleep(duration)
}

try app(.detect()).run()
