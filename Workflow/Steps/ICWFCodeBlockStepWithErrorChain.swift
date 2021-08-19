import UIKit

open class ICWFCodeBlockStepWithErrorChain: ICWFStepWithErrorChain {

    public var codeBlock:(_ currentStep: ICWFCodeBlockStepWithErrorChain) -> Void = {_ in }

    public override init() {
        super.init()
        self.stepDescription = "Execute code block"
    }

    open override func make() {
        super.make()
        doStep()
        complete()
    }

    func doStep() {
        codeBlock(self)
    }

    open override func cleanNewObject() -> AnyObject {
        return ICWFCodeBlockStepWithErrorChain()
    }

    open override func copyOfStep() -> AnyObject {
        let result = super.copyOfStep()
        if let stepCopy = result as? ICWFCodeBlockStepWithErrorChain {
            stepCopy.codeBlock = self.codeBlock
        }
        return result
    }
}
