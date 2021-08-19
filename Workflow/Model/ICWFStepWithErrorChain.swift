import UIKit

open class ICWFStepWithErrorChain: ICWFStep {

    private var _errorHandlingChain: ICWFChain!
    public var errorHandlingChain: ICWFChain { _errorHandlingChain }

    public override init() {
        super.init()
        _errorHandlingChain = newChain("On error")
    }

    public func completeWithError(_ errorData: NSObject?) {
        complete(withNextStep: errorHandlingChain.firstStep, andResult: errorData)
    }

    open override func cleanNewObject() -> AnyObject {
        return ICWFStepWithErrorChain()
    }

    open override func copyOfStep() -> AnyObject {
        let result = super.copyOfStep()
        if let stepCopy = result as? ICWFStepWithErrorChain {
            stepCopy.errorHandlingChain.firstStep = self.errorHandlingChain.firstStep
        }
        return result
    }
}
