import UIKit

private class CellModel {
    let hasMine: Bool
    var isDiscovered = false
    
    init(hasMine: Bool) {
        self.hasMine = hasMine
    }
}

final class MakabreViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private var valueMatrix: SquaredMatrix<CellModel>? {
        didSet {
            collectionView.reloadData()
        }
    }
    private let numberOfMines: Int
    private let totalMinefields: Int
    
    private var isWinGameAlertDisplayed = false
    
    
    var gameTimer: Timer?
    
    private lazy var rightBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: "Mines left: \(numberOfMines)", style: .plain, target: self, action: nil)
    }()
    private lazy var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: "Time: 00:00", style: .plain, target: self, action: nil)
    }()
    
    private var time: Double = 0
    
    private let spacing: CGFloat = 16.0     // the space between the cells
    
    init(numberOfMines: Int = 2, totalMinefields: Int = 25) {
        self.numberOfMines = numberOfMines
        self.totalMinefields = totalMinefields
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureCollectionView()
        startGame()
    }
    
    private func configureCollectionView() {
        collectionView.register(SquareCell.self, forCellWithReuseIdentifier: "Square") // registration of our custom cell
        
        collectionView.backgroundColor = UIColor.black
        
        // code to configure our cells layout - https://medium.com/@NickBabo/equally-spaced-uicollectionview-cells-6e60ce8d457b
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
    }
    
    // how many squares our board has
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let valueMatrix = valueMatrix else { return 0 }

        return Int(pow(Double(valueMatrix.squared), Double(2)))     // square the number of arrays our array has (5*5, 6*6...)
    }
    
    // how our layout looks equally spaced
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let valueMatrix = valueMatrix else { return CGSize(width: 0, height: 0) }

        let numberOfItemsPerRow = Double(valueMatrix.squared)   // 5
        
        let totalSpacing = (2 * spacing) + (numberOfItemsPerRow - 1) * spacing // Total spacing in a row (32 + 4*16) -> 32+64 = 96
        
        if let collection = self.collectionView {
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    // how our squares look
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Square", for: indexPath) as? SquareCell,
              let valueMatrix = valueMatrix else { fatalError("Unable to dequeue SquareCell")
        }
        
        let row = getRowAndColumn(from: indexPath).row
        let column = getRowAndColumn(from: indexPath).column
        
        if let cellModel = valueMatrix[row, column] { // constant hasMine checks if there's a mine in a cell with X row and Y column
            if cellModel.hasMine {
                cell.bg.image = UIImage(named: "bomb.png")
            } else {
                let mineCount = checkMineCount(row: row, column: column)
                if mineCount != 0 {
                    cell.bg.image = UIImage(named: "\(mineCount).png")   // the value of mines
                }
            }
            
            cell.cv.isHidden = cellModel.isDiscovered
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = getRowAndColumn(from: indexPath).row
        let column = getRowAndColumn(from: indexPath).column
        
        uncoverMinefield(row: row, column: column)
        
        collectionView.reloadData()
    }
    
    private func uncoverMinefield(row: Int, column: Int) {
        if let valueMatrix = valueMatrix, let cellModel = valueMatrix[row, column], !cellModel.isDiscovered {
            cellModel.isDiscovered = true
            
            if cellModel.hasMine {
                gameOver()
            } else if checkMineCount(row: row, column: column) == 0 {
                uncoverMinefield(row: row-1, column: column-1)
                uncoverMinefield(row: row-1, column: column)
                uncoverMinefield(row: row-1, column: column+1)
                uncoverMinefield(row: row, column: column-1)
                uncoverMinefield(row: row, column: column+1)
                uncoverMinefield(row: row+1, column: column-1)
                uncoverMinefield(row: row+1, column: column)
                uncoverMinefield(row: row+1, column: column+1)
            }
            
            checkIfIBeatTheGame()
        }
    }
    
    private func checkIfIBeatTheGame() {
        if !isWinGameAlertDisplayed {
            var count = 0
            var row = 0
            var column = 0
            while valueMatrix?[row,column] != nil {  // -2, -2
                while valueMatrix?[row,column] != nil {
                    count = valueMatrix?[row,column]?.isDiscovered == false ? count + 1 : count
                    column += 1
                }
                column = 0
                row += 1
            }
            
            if count == numberOfMines {
                isWinGameAlertDisplayed = true
                beatTheGame()
            }
        }
    }
    
    private func getRowAndColumn(from indexPath: IndexPath) -> (row: Int, column: Int) {
        guard let valueMatrix = valueMatrix else { return (-1, -1) }
        let row = indexPath.item / valueMatrix.squared      // will iterate all the content of our collectionView
        let column = indexPath.item % valueMatrix.squared
        
        return (row, column)
    }
    
    // func to check mines in the nearby cells for each cell
    private func checkMineCount(row: Int, column: Int) -> Int {
        guard let valueMatrix = valueMatrix else { return -1 }
        let valuesToCheck = [valueMatrix[row-1, column-1], valueMatrix[row-1, column], valueMatrix[row-1, column+1],
                             valueMatrix[row, column-1], valueMatrix[row, column+1],
                             valueMatrix[row+1, column-1], valueMatrix[row+1, column], valueMatrix[row+1, column+1]]
        
        return valuesToCheck.filter { $0?.hasMine == true }.count
    }
    
    private func configureNavigation() {    // UI of our app
        title = "Minesweeper"
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        rightBarButtonItem.title = "Mines left: \(numberOfMines)"
        
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
            self?.startGame()
        })
        ac.addAction(UIAlertAction(title: "No", style: .destructive) {    // does nothing //.destructive tints the button to red
            [weak self] _ in
            self?.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self!, selector: #selector(self?.timerCounter), userInfo: nil, repeats: true)       // pending to check self! with Makabre
        })
        present(ac, animated: true)
    }
    
    private func gameOver() { // method to reset the game
        gameTimer?.invalidate()
        let ac = UIAlertController(title: "You lost!", message: "Fill, caca al cap", preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Play again", style: .default) {     // resets the game
            [weak self] _ in
            self?.startGame()
        })
        present(ac, animated: true)
    }
    
    private func beatTheGame() { // method to reset the game
        gameTimer?.invalidate()
        let ac = UIAlertController(title: "You won!!", message: "Fill, caca al cap", preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Play again", style: .default) {     // resets the game
            [weak self] _ in
            self?.startGame()
        })
        present(ac, animated: true)
    }
    
    private func startGame() {
        var values = Array(repeating: true, count: numberOfMines) + Array(repeating: false, count: totalMinefields - numberOfMines)
        values.shuffle()
        valueMatrix = try? SquaredMatrix(values.map { CellModel(hasMine: $0) })    // create an array of arrays using "values"
        time = 0
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        isWinGameAlertDisplayed = false
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
    }
}


/*
 Logic
 
 didSelectItemAt: show the image when the cell is clicked
    
        if has a bomb = game over = stop timer, minecounter -= 1, offer a restart (randomize the array valueMatrix)
        else = the game goes on and the image does not disappear
  
 optional: mark the bombs?
 
 */
