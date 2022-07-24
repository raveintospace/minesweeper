import Foundation

enum MatrixError: Error {
    case valuesNotSquared
}

struct SquaredMatrix<Element> {
    private let container: [[Element]]
    
    var squared: Int {
        container.count
    }
    
    init(_ array: [Element]) throws {
        self.container = try array.splitArrayIntoSquaredSubarrays()
    }
    
    subscript(row: Int, column: Int) -> Element? {
        guard row >= 0, column >= 0, row < container.count, column < container.count else {
            return nil
        }
        return container[row][column]
    }
}

private extension Array  {
    func splitArrayIntoSquaredSubarrays() throws -> [[Element]] {
        guard self.count.isPerfectSquare else {
            throw MatrixError.valuesNotSquared
        }
        var result: [[Element]] = []
        let root = Int(Double(count).squareRoot())
        for index in 0...root-1 {
            result.append(Array(self[index*root...root-1 + index*root]))
        }
        return result
    }
}
