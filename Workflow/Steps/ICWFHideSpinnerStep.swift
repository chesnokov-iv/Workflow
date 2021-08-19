// import UIKit
// 
// open class ICWFHideSpinnerStep: ICWFStep {
//    
//    private var _spinnerManager: SpinnerManager!
//    
//    public init(with spinnerManager: SpinnerManager) {
//        super.init()
//        _spinnerManager = spinnerManager
//        self.stepDescription = "Hide spinner"
//    }
//    
//    open override func make() {
//        super.make()
//        doStep()
//        complete()
//    }
//    
//    func doStep() {
//        _spinnerManager.hideSpinner()
//    }
//    
//    open override func copyOfStep() -> AnyObject {
//        let result = super.copyOfStep() as! ICWFHideSpinnerStep
//        return result
//    }
// }
