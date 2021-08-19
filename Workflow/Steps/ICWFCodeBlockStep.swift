import UIKit

open class ICWFCodeBlockStep: ICWFStep {

    public var codeBlock:(_ currentStep: ICWFCodeBlockStep) -> Void = {_ in }

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
        return ICWFCodeBlockStep()
    }

    open override func copyOfStep() -> AnyObject {
        let result = super.copyOfStep()
        if let stepCopy = result as? ICWFCodeBlockStep {
            stepCopy.codeBlock = self.codeBlock
        }
        return result
    }
}
