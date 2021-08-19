import UIKit

public class ICWFChain: NSObject {
    var chainDescription: NSString?
    var firstStep: ICWFStep?

    init(withDescription chainDescription_p: NSString) {
        self.chainDescription = chainDescription_p
    }
}
