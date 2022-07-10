//
//  ViewController.swift
//  Minesweeper
//
//  Created by Uri on 3/7/22.
//

import UIKit

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout { // delegate is necessary to programatically code our equal spacing
    
    var gameTimer: Timer?
    
    var minesList = [false, true, false, false, false, true, true, false, false, false, false, true, false, true, false, false, false, true, false, false, false, true, true, false, false] // pending to check if number of booleans has a sqr
    var minesCount: Int {
        minesList.filter{ $0 == true }.count
    }
    
    private lazy var rightBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: "Mines left: \(minesCount)", style: .plain, target: self, action: nil)
    }()
    private lazy var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: "Time: 00:00", style: .plain, target: self, action: nil)
    }()
    
    private var mines = 0 {
        didSet {
            rightBarButtonItem.title = "Mines left: \(minesCount)"
         }
     }
    private var time: Double = 0
    
    private let spacing: CGFloat = 16.0     // the space between the cells
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SquareCell.self, forCellWithReuseIdentifier: "Square") // registration of our custom cell
        
        configureNavigation()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        
        // code to configure our cells layout - https://medium.com/@NickBabo/equally-spaced-uicollectionview-cells-6e60ce8d457b
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
    }
    
    // how many squares our board has
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return minesList.count
    }
    
    // how our layout looks equally spaced
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow = sqrt(Double(minesList.count))
        let spacingBetweenCells: CGFloat = 16
        
        let totalSpacing = (2 * self.spacing) + (numberOfItemsPerRow - 1) * spacingBetweenCells // Total spacing in a row
        print(self.spacing)
        
        if let collection = self.collectionView {
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            print(collection.bounds.width)
            print(totalSpacing)
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    // how our squares look
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Square", for: indexPath) as? SquareCell else { fatalError("Unable to dequeue SquareCell")
        }
        
        let mineCell = minesList[indexPath.item]
        if mineCell == true {
            cell.backgroundColor = UIColor.red
            print("true")
        } else {
            cell.backgroundColor = UIColor.green
            print("false")
        }
    
        return cell
    }
    
    private func configureNavigation() {    // UI of our app
        title = "Minesweeper"
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetGame))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) // used to center resetButton
        toolbarItems = [spacer, resetButton, spacer]
        navigationController?.isToolbarHidden = false
    }
    
    @objc func resetGame() { // method to reset the game
        let ac = UIAlertController(title: "Reset game", message: "Do you want to reset the game?", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Yes", style: .default) {     // resets the game
            [weak self] _ in
            self?.time = 0
        })
        ac.addAction(UIAlertAction(title: "No", style: .destructive))    // does nothing //.destructive tints the button to red
        present(ac, animated: true)
    }

    // func to convert our "time" (Double) into a string - https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds/56811188#56811188?newreg=7c7f69c3286442c38ae7bca11b9ed359 (Swift 5)
    private func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        return String(format: "%02i:%02i", minute, second)
    }
    
    // func called every second to update our timer
    @objc func timerCounter() {
        time += 1
        leftBarButtonItem.title = "Time: \(timeString(time: time))"
        print(timeString(time: time))
    }
    
}


