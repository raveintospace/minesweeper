import UIKit

import Foundation

let numberOfItemsPerRow = Double(5)
let spacing = 16.0

let totalSpacing = (2 * spacing) + (numberOfItemsPerRow - 1) * spacing
print(totalSpacing)
//if let collection = self.collectionView {
//    let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
//    // print(collection.bounds.width)
//    print(totalSpacing)
//    return CGSize(width: width, height: width)
//} else {
//    return CGSize(width: 0, height: 0)
//}
