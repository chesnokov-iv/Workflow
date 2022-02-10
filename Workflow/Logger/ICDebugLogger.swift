import UIKit

open class ICDebugLogger: ICBaseLogger {
    public override func log(_ message: String) {
        print(message)
    }
}
