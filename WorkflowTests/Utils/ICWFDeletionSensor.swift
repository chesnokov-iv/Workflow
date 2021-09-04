import UIKit

class ICWFDeletionSensor: NSObject {
    public weak var objectToWatch: NSObject?
    
    init(withObjectToWatch: NSObject?) {
        super.init()
        objectToWatch = withObjectToWatch
    }
}
