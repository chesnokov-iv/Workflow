// import UIKit
//
// open class ICWFShowSpinnerStep: ICWFStep {
//    
//    private var _spinnerManager: SpinnerManager!
//    
//    public init(with spinnerManager: SpinnerManager) {
//        super.init()
//        _spinnerManager = spinnerManager
//        self.stepDescription = "Show spinner"
//    }
//    
//    open override func make() {
//        super.make()
//        doStep()
//        complete()
//    }
//    
//    func doStep() {
//        _spinnerManager.showSpinner()
//    }
//    
//    open override func copyOfStep() -> AnyObject {
//        let result = super.copyOfStep() as! ICWFShowSpinnerStep
//        return result
//    }
// }
