//
//  ViewController.swift
//  Minesweeper
//
//  Created by Uri on 3/7/22.
//

import UIKit

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout { // delegate is necessary to programatically code our equal spacing
    
    var gameTimer: Timer?
    
    private var minesData = [MineData]()    // array of MineData
    
    private var imageData = [String]()      // array of strings with our images names
    
    private var cellList = [false, true, false, false, false, true, true, false, false, false, false, true, false, true, false, false, false, true, false, false, false, true, true, false, false] // add one bool to check hasPerfectSquare()
    private var minesCount: Int {
        cellList.filter{ $0 == true }.count
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
        
        hasPerfectSquare()
        
        collectionView.register(SquareCell.self, forCellWithReuseIdentifier: "Square") // registration of our custom cell
        
        configureNavigation()
        configureDataSet()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        
        print("cellCount: \(cellList.count)")
        
        // code to configure our cells layout - https://medium.com/@NickBabo/equally-spaced-uicollectionview-cells-6e60ce8d457b
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
    }
    
    // how many squares our board has
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellList.count
    }
    
    // how our layout looks equally spaced
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow = sqrt(Double(cellList.count))
        let spacingBetweenCells: CGFloat = 16
        
        let totalSpacing = (2 * self.spacing) + (numberOfItemsPerRow - 1) * spacingBetweenCells // Total spacing in a row, pendent consultar makabre
        
        if let collection = self.collectionView {
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            // print(collection.bounds.width)
            // print(totalSpacing)
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    // how our squares look - phase 1
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Square", for: indexPath) as? SquareCell else { fatalError("Unable to dequeue SquareCell")
//        }
//
//        let mineCell = cellList[indexPath.item]
//        if mineCell == true {
//            cell.backgroundColor = UIColor.red
//            // print("true")
//        } else {
//            cell.backgroundColor = UIColor.green
//            // print("false")
//        }
//
//        return cell
//    }
    
    // how our squares look - phase 2
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Square", for: indexPath) as? SquareCell else { fatalError("Unable to dequeue SquareCell")
        }
        
        let mineCell = minesData[indexPath.item]
        if mineCell.hasMine == true {
            cell.backgroundColor = UIColor.red
            cell.bg.image = UIImage(named: imageData[0])
            // print("true")
        } else {
            cell.backgroundColor = UIColor.green
            cell.bg.image = UIImage(named: imageData[2])
            // print("false")
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
        gameTimer?.invalidate()
        let ac = UIAlertController(title: "Reset game", message: "Do you want to reset the game?", preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Yes", style: .default) {     // resets the game
            [weak self] _ in
            self?.time = 0
            self?.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self!, selector: #selector(self?.timerCounter), userInfo: nil, repeats: true)
            
        })
        ac.addAction(UIAlertAction(title: "No", style: .destructive) {    // does nothing //.destructive tints the button to red
            [weak self] _ in
            self?.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self!, selector: #selector(self?.timerCounter), userInfo: nil, repeats: true)       // pending to check self! with Makabre
        })
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
        // print(timeString(time: time))
    }
    
    // func to add true & falses if cellList.isPerfectSquare returns false -- pending to recalculate numberOfItemsPerRow
    private func hasPerfectSquare() {
        var cellCountInFunc = cellList.count
        
        while cellCountInFunc.isPerfectSquare == false {
            cellCountInFunc += 1
            cellList.append(Bool.random())
            print("fato", cellCountInFunc)
        }
    }
    
    private func configureDataSet() {
        let fm = FileManager.default            // data type that lets us work with the filesystem
        let path = Bundle.main.resourcePath!    // where I can find all those images I added to my app.
        let images = try! fm.contentsOfDirectory(atPath: path).sorted() // The images constant will be an array of strings containing filenames.
        
        for image in images {               // append the string of each filename to our imageData array
            if image.hasSuffix(".png") {
                imageData.append(image)
            }
        }
        print(imageData) // pending to alphabetically sort our imageData array
        
        for item in cellList {
            if item == false {  // append to MinesData, setting the string for the imagePath. 5 different indicators
                minesData.append(MineData(hasMine: false, imagePath: "one.png"))
            } else {    // append to MinesData, setting the string for the bomb image
                minesData.append(MineData(hasMine: true, imagePath: "bomb.png"))
            }
        }
    }
    
    
} // last brace

// extension to check if an Int has a perfectSquare
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

struct MineData {
    let hasMine: Bool
    let imagePath: String  // an image showing a bomb or a number with nearby bombs
}


