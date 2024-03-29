//
//  Square.swift
//  Minesweeper
//
//  Created by Uri on 4/7/22.
// https://medium.com/@max.codes/programmatic-custom-collectionview-cell-subclass-in-swift-5-xcode-10-291f8d41fdb1

import UIKit

class SquareCell: UICollectionViewCell {
    let bg: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage()
        imageView.layer.cornerRadius = 12
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.yellow.cgColor
        return imageView
    }()
    
    let cv: UIView = {
        let cellView = UIView()
        cellView.translatesAutoresizingMaskIntoConstraints = false
        cellView.clipsToBounds = true
        cellView.backgroundColor = UIColor.darkGray
        cellView.layer.borderWidth = 3
        cellView.layer.borderColor = UIColor.white.cgColor
        return cellView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(bg)
        contentView.addSubview(cv)
        
        bg.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bg.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        bg.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        cv.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cv.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        cv.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        cv.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {   // necessary when reusing dequeueReusableCells, avoids reusing data from previous cells
        bg.image = nil
    }
}
