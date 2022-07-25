import Foundation

enum MatrixError: Error {
    case valuesNotSquared
}

struct SquaredMatrix<Element> {
    private let container: [[Element]]      // container is an array of arrays containing something (element)
    
    var squared: Int {
        container.count     // how many arrays has container
    }
    
    init(_ array: [Element]) throws {
        self.container = try array.splitArrayIntoSquaredSubarrays()
    }
    
    subscript(row: Int, column: Int) -> Element? {
        guard row >= 0, column >= 0, row < container.count, column < container.count else {
            return nil  // return nil if column or row are small than 0 or bigger than container.count
        }
        return container[row][column]   // will return [0,1] for instance
    }
}

private extension Array  {
    func splitArrayIntoSquaredSubarrays() throws -> [[Element]] {
        guard self.count.isPerfectSquare else {     // check if the array we have has a perfect square
            throw MatrixError.valuesNotSquared      // throw the error if it has no perfect square
        }
        var result: [[Element]] = []
        let root = Int(Double(count).squareRoot())  // the result of squaring the count of items in container (squared 25 = 5)
        for index in 0...root-1 {
            result.append(Array(self[index*root...root-1 + index*root]))    // create one array from 0 to 4, next from 5 to 9, etc
        }
        return result
    }
}
