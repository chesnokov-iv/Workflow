import UIKit

open class ICWFInitWithValueStep: ICWFStep {

    var _value: NSObject?

    public init(with value: NSObject?) {
        super.init()
        _value = value
        self.stepDescription = "Load value: [\(String(describing: _value))]" as NSString
    }

    open override func make() {
        output = _value
        complete()
    }
}
