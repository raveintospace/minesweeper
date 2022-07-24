import UIKit

final class MakabreViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let valueMatrix: SquaredMatrix<Bool>
    
    var gameTimer: Timer?
    
    private var minesData = [MineData]()    // array of MineData
    
    private var imageData = [String]()      // array of strings with our images names
    
     // add one bool to check hasPerfectSquare() works
   
    private var minesCount: Int {
        999
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
    
    init(values: [Bool] = [false, true, false, false, false, true, true, false, false, false, false, true, false, true, false, false, false, true, false, false, false, true, true, false, false]) throws {
        self.valueMatrix = try SquaredMatrix(values)
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView.register(SquareCell.self, forCellWithReuseIdentifier: "Square") // registration of our custom cell
        
        // code to configure our cells layout - https://medium.com/@NickBabo/equally-spaced-uicollectionview-cells-6e60ce8d457b
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
    }
    
    // how many squares our board has
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(pow(Double(valueMatrix.squared), Double(2)))
    }
    
    // how our layout looks equally spaced
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow = Double(valueMatrix.squared)
        
        let totalSpacing = (2 * spacing) + (numberOfItemsPerRow - 1) * spacing // Total spacing in a row, pendent consultar makabre
        
        if let collection = self.collectionView {
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    // how our squares look - phase 2
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Square", for: indexPath) as? SquareCell else { fatalError("Unable to dequeue SquareCell")
        }
        
        let row = indexPath.item / valueMatrix.squared
        let column = indexPath.item % valueMatrix.squared
        
        if let hasMine = valueMatrix[row, column] {
            if hasMine {
                cell.bg.image = UIImage(named: "bomb.png")
            } else {
                cell.bg.image = UIImage(named: "\(checkMineCount(row: row, column: column)).png")
            }
        }
        
        return cell
    }
    
    private func checkMineCount(row: Int, column: Int) -> Int {
        let valuesToCheck = [valueMatrix[row-1, column-1], valueMatrix[row-1, column], valueMatrix[row-1, column+1],
                             valueMatrix[row, column-1], valueMatrix[row, column+1],
                             valueMatrix[row+1, column-1], valueMatrix[row+1, column], valueMatrix[row+1, column+1]]
        
        return valuesToCheck.filter { $0 == true }.count
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
}
