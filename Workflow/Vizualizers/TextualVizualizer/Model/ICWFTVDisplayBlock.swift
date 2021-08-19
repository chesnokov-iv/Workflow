import UIKit

open class ICWFTVDisplayBlock: NSObject {

    private var _strings: [String] = []
    public var strings: [String] { _strings }

    private var _maxWidth: Int = 0
    public var maxWidth: Int { _maxWidth }

    public func addString(_ newString: NSString) {
        let subStrings = newString.components(separatedBy: "\n")
        for subString in subStrings {
            if subString.count > _maxWidth { _maxWidth = subString.count }
            _strings.append(subString)
        }
    }

    open func renderWithWidth(_ requiredWidth: Int) -> String {
        return ""
    }

    public func line(with symbol: String, count: Int) -> String {
        var result = ""
        for _ in 0..<count {
            result.append(symbol)
        }
        return result
    }
}
