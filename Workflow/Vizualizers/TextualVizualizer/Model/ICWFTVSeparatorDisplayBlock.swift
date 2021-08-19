import UIKit

open class ICWFTVSeparatorDisplayBlock: ICWFTVDisplayBlock {

    open override func renderWithWidth(_ requiredWidth: Int) -> String {
        return line(with: "*", count: requiredWidth) + "\n"
    }

}
