import UIKit

class ICWFTestableStep: ICWFStep {
    
    private var stringsArray = NSMutableArray()
    
    public init(withDescription: NSString, and stringsArray: NSMutableArray) {
        super.init()
        self.stepDescription = withDescription
        self.stringsArray = stringsArray
    }
    
    override func make() {
        output = input
        stringsArray.add(stepDescription ?? "ICWF: unknown")
        complete()
    }
}
