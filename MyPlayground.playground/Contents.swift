import UIKit

import Foundation

struct SquaredMatrix<Element> {
    private let container: [[Element]]
    
    init(_ array: [Element]) throws {
        // TODO: @hardschool Check array.count es arrel quadrada, else throws
        // TODO: @hardschool Split array en subarrais del mateix tamany
        container = []
    }
    
    subscript(row: Int, column: Int) -> Element? {
        return nil
    }
}

let boolMatrix = try SquaredMatrix([true, true])
let intMatrix = try SquaredMatrix([1, 2])
let stringMatrix = try SquaredMatrix(["1", "2"])

let bool = boolMatrix[0, 1]
