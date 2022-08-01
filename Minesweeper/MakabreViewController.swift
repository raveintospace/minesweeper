import UIKit

// class to be used in didSelectItemAt
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
            collectionView.reloadData()     // everytime we create start a game
        }
    }
    
    private let numberOfMines: Int
    private let totalMinefields: Int
    
    private var isWinGameAlertDisplayed = false     // to avoid being shown more than once
    
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
        guard let valueMatrix = valueMatrix else { return CGSize(width: 0, height: 0) } // check if valueMatrix exists

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
        
        if let cellModel = valueMatrix[row, column] { // checks if there's a mine in a cell with X row and Y column
            if cellModel.hasMine {
                cell.bg.image = UIImage(named: "bomb.png")
            } else {
                let mineCount = checkMineCount(row: row, column: column)
                if mineCount != 0 {     // if it's 0 we don't pain any image
                    cell.bg.image = UIImage(named: "\(mineCount).png")   // the value of mines
                }
            }
            
            cell.cv.isHidden = cellModel.isDiscovered // assign to isHidden the value of isDiscovered (false by default)
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
            cellModel.isDiscovered = true       // true means that we hide the CV and the image under it is shown
            
            if cellModel.hasMine {
                gameOver()
            } else if checkMineCount(row: row, column: column) == 0 {       // cascade mode for cells with 0 mineCount
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
    
    // to check if we have discovered all the cells with no bombs = win the game
    private func checkIfIBeatTheGame() {
        if !isWinGameAlertDisplayed {
            var count = 0       // number of non discovered cells, reseted to 0 everytime it is called
            var row = 0
            var column = 0
            while valueMatrix?[row,column] != nil {  // -1, -1
                while valueMatrix?[row,column] != nil {     // -1, 5
                    count = valueMatrix?[row,column]?.isDiscovered == false ? count + 1 : count
                    print(count)
                    column += 1     // to check each line
                }
                column = 0      // once the line is checked, we jump to the line below
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
        let row = indexPath.item / valueMatrix.squared
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
        let ac = UIAlertController(title: "You lose!", message: "A bomb killed you", preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Play again", style: .default) {     // resets the game
            [weak self] _ in
            self?.startGame()
        })
        present(ac, animated: true)
    }
    
    private func beatTheGame() { // method to reset the game
        gameTimer?.invalidate()
        let ac = UIAlertController(title: "You win!", message: "You avoided all the bombs", preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Play again", style: .default) {     // resets the game
            [weak self] _ in
            self?.startGame()
        })
        present(ac, animated: true)
    }
    
    private func startGame() {
        var values = Array(repeating: true, count: numberOfMines) + Array(repeating: false, count: totalMinefields - numberOfMines)
        values.shuffle()
        valueMatrix = try? SquaredMatrix(values.map { CellModel(hasMine: $0) })    // create an array of arrays using the bool value of hasMine, we obtain an array of trues & falses
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


/*
 TO DO
 
 alert controller for the user to choose how many cells and bombs
 the alert has to check that the number input by the user hasperfectSquare
 
 */
