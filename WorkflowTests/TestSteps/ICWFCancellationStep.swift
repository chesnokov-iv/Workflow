import UIKit

class ICWFCancellationStep: ICWFStep {
        
    override func make() {
        output = input
        owner?.cancel()
        complete()
    }
}
