// import UIKit
// 
// open class ICWFDisplayErrorInfoStep: ICWFStep {
//    
//    public override init() {
//        super.init()
//        self.stepDescription = "Display error info"
//    }
//    
//    open override func make() {
//        
//        guard let errorInfo = safe(object: input, ofClass: ErrorInfo.self) as? ErrorInfo else {
//            super.make()
//            complete()
//            return
//        }
//        
//        weak var weakSelf = self
//        AlertManager.showSimpleErrorAlert(with: errorInfo) {
//            weakSelf?.complete()
//        }
//    }
//    
//    open override func copyOfStep() -> AnyObject {
//        let result = super.copyOfStep() as! ICWFDisplayErrorInfoStep
//        return result
//    }
// 
// }
