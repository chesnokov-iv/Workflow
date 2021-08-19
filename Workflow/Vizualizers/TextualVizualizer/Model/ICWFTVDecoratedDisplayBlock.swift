import UIKit

open class ICWFTVDecoratedDisplayBlock: ICWFTVDisplayBlock {

    open override func renderWithWidth(_ requiredWidth: Int) -> String {
        let topDecorator = line(with: "-", count: requiredWidth)
        let bottomDecorator = topDecorator
        let sideDecorator = "|"

        var result = ""
        result.append(topDecorator + "\n")

        for string in self.strings {
            let spaces = (requiredWidth - string.count - sideDecorator.count * 2) / 2
            let spacesBlock = line(with: " ", count: spaces)
            result.append(sideDecorator)
            result.append(spacesBlock)
            result.append(string)
            result.append(spacesBlock)
            result.append(sideDecorator)
            result.append("\n")
        }

        result.append(bottomDecorator + "\n")
        return result
    }

}
