import UIKit

open class ICWFAsyncCodeBlockStepWithErrorChain: ICWFStepWithErrorChain {

    var codeBlock:(_ currentStep: ICWFAsyncCodeBlockStepWithErrorChain) -> Void = {_ in }

    public override init() {
        super.init()
        self.stepDescription = "Execute asynchronous code block"
    }

    open override func make() {
        super.make()
        doStep()
    }

    func doStep() {
        codeBlock(self)
    }

    open override func cleanNewObject() -> AnyObject {
        return ICWFAsyncCodeBlockStepWithErrorChain()
    }

    open override func copyOfStep() -> AnyObject {
        let result = super.copyOfStep()
        if let stepCopy = result as? ICWFAsyncCodeBlockStepWithErrorChain {
            stepCopy.codeBlock = self.codeBlock
        }
        return result
    }
}
