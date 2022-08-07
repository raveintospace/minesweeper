// view model to store the business logic of our app

import Foundation

class MakabreViewModel {
    
    var resetTitle = "Reset game"
    var resetMessage = "Do you want to reset the game?"
    var resetYes = "Yes"
    var resetNo = "No"

    
    
}

extension BinaryInteger {   // https://stackoverflow.com/questions/43301933/swift-3-find-if-the-number-is-a-perfect-square 
    var isPerfectSquare: Bool {
        guard self >= .zero else { return false }
        var sum: Self = .zero
        var count: Self = .zero
        var squareRoot: Self = .zero
        while sum < self {
            count += 2
            sum += count
            squareRoot += 1
        }
        return squareRoot * squareRoot == self
    }
}
