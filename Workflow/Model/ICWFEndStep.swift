import UIKit

public class ICWFEndStep: ICWFStep {
    public override init() {
        super.init()
        stepDescription = "Finalize and destroy workflow"
    }

    public override func make() {
        nextChain.firstStep = nil
        owner?.destroy()
        complete()
    }
}
