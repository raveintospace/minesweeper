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
    
    private var cellList = [false, true, false, false, false, true, true, false, false, false, false, true, false, true, false, false, false, true, false, false, false, true, true, false, false] // add one bool to check hasPerfectSquare() works
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
        calculateNearbyMines()
        
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
            cell.bg.image = UIImage(named: imageData[0])
        } else {
            cell.bg.image = UIImage(named: imageData[2])
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
        var cellCount = cellList.count
        
        while cellCount.isPerfectSquare == false {
            cellCount += 1
            cellList.append(Bool.random())
            print("fato", cellCount)
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
    
    private func calculateNearbyMines() {
        let numberOfItemsPerRow = sqrt(Double(cellList.count))
        let intNumberOfItemsPerRow = Int(numberOfItemsPerRow)
        let negativeNumberOfItemsPerRow = -intNumberOfItemsPerRow  // -5
        let numberOfItemsPerRowPlusOne = intNumberOfItemsPerRow + 1    // 6
        let numberOfItemsPerRowMinusOne = intNumberOfItemsPerRow - 1   // 4
        let negativeNumberOfItemsPerRowMinusOne = -intNumberOfItemsPerRow - 1 // -6
        let negativeNumberOfItemsPerRowPlusOne = -intNumberOfItemsPerRow + 1   // -4
        
        // block of cells with 3 checks
        for mineData in minesData {
            
            // first row, first column
            if mineData == minesData[0] {
                switch (minesData[1].hasMine, minesData[intNumberOfItemsPerRow].hasMine, minesData[numberOfItemsPerRowPlusOne].hasMine) {
                case(true, true, true):
                    minesData[0].mineCounter = 3
                case(false, true, true):
                    minesData[0].mineCounter = 2
                case(true, false, true):
                    minesData[0].mineCounter = 2
                case(true, true, false):
                    minesData[0].mineCounter = 2
                case(false, false, true):
                    minesData[0].mineCounter = 1
                case(true, false, false):
                    minesData[0].mineCounter = 1
                case(false, true, false):
                    minesData[0].mineCounter = 1
                case(false, false, false):
                    minesData[0].mineCounter = 0
                }
                print("Cela 0: \(minesData[0].mineCounter)")
            }
            
            // first row, last column
            if mineData == minesData[numberOfItemsPerRowMinusOne] {
                switch (minesData[(numberOfItemsPerRowMinusOne) - (1)].hasMine, minesData[(numberOfItemsPerRowMinusOne) + (numberOfItemsPerRowMinusOne)].hasMine, minesData[(numberOfItemsPerRowMinusOne) + (intNumberOfItemsPerRow)].hasMine) {
                case(true, true, true):
                    minesData[numberOfItemsPerRowMinusOne].mineCounter = 3
                case(false, true, true):
                    minesData[numberOfItemsPerRowMinusOne].mineCounter = 2
                case(true, false, true):
                    minesData[numberOfItemsPerRowMinusOne].mineCounter = 2
                case(true, true, false):
                    minesData[numberOfItemsPerRowMinusOne].mineCounter = 2
                case(false, false, true):
                    minesData[numberOfItemsPerRowMinusOne].mineCounter = 1
                case(true, false, false):
                    minesData[numberOfItemsPerRowMinusOne].mineCounter = 1
                case(false, true, false):
                    minesData[numberOfItemsPerRowMinusOne].mineCounter = 1
                case(false, false, false):
                    minesData[numberOfItemsPerRowMinusOne].mineCounter = 0
                }
                print("Cela 4: \(minesData[numberOfItemsPerRowMinusOne].mineCounter)")
            }
            
            
            // last row, first column
            if mineData == minesData[(cellList.count) - (intNumberOfItemsPerRow)] {
                var minesToCheck = [minesData[(cellList.count) - (intNumberOfItemsPerRow * 2)], minesData[(cellList.count) - (intNumberOfItemsPerRow * 2) + 1], minesData[(cellList.count) - numberOfItemsPerRowMinusOne]]
                for item in minesToCheck {
                    if item.hasMine == true {
                        minesData[(cellList.count) - (intNumberOfItemsPerRow)].mineCounter += 1
                    }
                }
                print("Cela 20: \(minesData[(cellList.count) - (intNumberOfItemsPerRow)].mineCounter)")
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

struct MineData: Equatable {
    let hasMine: Bool
    let imagePath: String  // an image showing a bomb or a number with nearby bombs
    var mineCounter = 0
}


/*
 ---- LOGICA PER DETECTAR MINES ----
 
 1st item 1st row & last item 1st row -> check 3
    1st item always = indexpath 0 --- +1, +5, +6
    last item 1st row = numberOfItemsPerRow - 1 (ie 4) --- -1, +4, +5
 1st item last row & last item last row -> check 3
    1st item last row = cellList.count - numberOfItemsPerRow (ie 25 - 5) --- -5, -4, +1 (inversa last 1st)
    last item last row = cellList.count - 1 (ie 24) --- -6, -5, -1 (inversa 1st)
 
 rest items of 1st row -> check 5
    for cell between indexpath[0] & indexpath[(numberOfitemspPerRow - 1)] --- -1, +1, +4, +5, +6
 rest items of 1st column -> check 5
    for cell indexpath[x] % numberOfItemsPerRow = 0 // as many times as numberOfItemsPerRow - 2 (-2 are the two corners)
        -5, -4, +1, +5, +6
 rest items of last row -> check 5
    for cell between indexpath[1stItemLastRow] & indexpath[cellList.count - 1] --- -6, -5, -4, -1, +1 (inversa!)
 rest items of last column -> check 5
    for cell indexpath[x] % numberOfItemsPerRow = 4 // as many times as numberOfItemsPerRow - 2 (-2 are the two corners)
        -6, -5, -1, +4, +5 (inversa)
 
 rest items -> check 8  --- -6, -5, -4, -1, +1, +4, +5, +6
        
 let numberOfItemsPerRow = 5 //      let numberOfItemsPerRow = sqrt(Double(cellList.count))
 let negativeNumberOfItemsPerRow = -numberOfItemsPerRow  // -5
 let numberOfItemsPerRowPlusOne = numberOfItemsPerRow + 1    // 6
 let numberOfItemsPerRowMinusOne = numberOfItemsPerRow - 1   // 4
 let negativeNumberOfItemsPerRowMinusOne = -numberOfItemsPerRow - 1 // -6
 let negativeNumberOfItemsPerRowPlusOne = -numberOfItemsPerRow + 1   // -4
 
 donar nom a cada tipus de grup de cela xq a l'iniciar el joc s'agrupin
 calcular les sumes i restes en base al valor de numberOfItemsPerRow (ie numberOfItemsPerRow + 1 = 6), pq s'adapti a grids amb mes celes.
 PREGUNTAR A MAKABRE SI numberOfItemsPerRow el podem calcular abans de viewDidLoad
 */
