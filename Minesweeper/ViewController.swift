//
//  ViewController.swift
//  Minesweeper
//
//  Created by Uri on 3/7/22.
//

import UIKit

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout { // delegate is necessary to programatically code our equal spacing
    
    var gameTimer: Timer?
    
    private var minesList = [false, true, false, false, false, true, true, false, false, false, false, true, false, true, false, false]
    
    private lazy var rightBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: "Mines left: 0", style: .plain, target: self, action: nil)
    }()
    private lazy var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: "Time: 0", style: .plain, target: self, action: nil)
    }()
    
    private var mines = 0 {
        didSet {
            rightBarButtonItem.title = "Mines left: \(mines)"
        }
    }
    private var time = 0 {
        didSet {
            leftBarButtonItem.title = "Time: \(time)"
        }
    }
    
    private let spacing: CGFloat = 16.0     // the space between the cells
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addOne), userInfo: nil, repeats: true)
        
        // code to configure our cells layout - https://medium.com/@NickBabo/equally-spaced-uicollectionview-cells-6e60ce8d457b
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
    }
    
    // how many squares our board has
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    // how our layout looks equally spaced
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 4
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
        ac.addAction(UIAlertAction(title: "No", style: .cancel))    // does nothing
        present(ac, animated: true)
    }
    
    @objc func addOne() {
        time += 1
    }

    
// https://www.youtube.com/watch?v=3TbdoVhgQmE
//    private func configureTimer() {
//        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
//    }
//
//    @objc func timerCounter() -> Void {
//        time += 1
//        let newTime = secondsToMinutes(seconds: time)
//        newTimeString = makeTimeString(minutes: newTime.0, seconds: newTime.1)
//        leftBarButtonItem.title = "Time: \(newTimeString)"
//    }
//
//    private func secondsToMinutes(seconds: Int) -> (Int, Int) {
//        return ((seconds / 3600), ((seconds % 3600 / 60)))
//    }
//
//    private func makeTimeString(minutes: Int, seconds: Int) -> String {
//        var timeString = ""
//        timeString += String(format: "%02i", minutes)
//        timeString += " : "
//        timeString += String(format: "%02i", seconds)
//        return timeString
//    }

}

