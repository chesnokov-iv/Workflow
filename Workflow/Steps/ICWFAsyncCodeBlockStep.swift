import UIKit

open class ICWFAsyncCodeBlockStep: ICWFStep {

    var codeBlock:(_ currentStep: ICWFAsyncCodeBlockStep) -> Void = {_ in }

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
        return ICWFAsyncCodeBlockStep()
    }

    open override func copyOfStep() -> AnyObject {
        let result = super.copyOfStep()
        if let stepCopy = result as? ICWFAsyncCodeBlockStep {
            stepCopy.codeBlock = self.codeBlock
        }
        return result
    }
}
