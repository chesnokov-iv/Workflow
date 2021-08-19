import UIKit

open class ICWFTVUnDecoratedDisplayBlock: ICWFTVDisplayBlock {

    open override func renderWithWidth(_ requiredWidth: Int) -> String {
        var result = ""

        for string in self.strings {
            let spaces = (requiredWidth - string.count) / 2
            let spacesBlock = line(with: " ", count: spaces)
            result.append(spacesBlock)
            result.append(string)
            result.append(spacesBlock)
            result.append("\n")
        }

        return result
    }

}
