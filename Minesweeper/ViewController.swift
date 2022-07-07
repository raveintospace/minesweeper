//
//  ViewController.swift
//  Minesweeper
//
//  Created by Uri on 3/7/22.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var gameTimer: Timer?
    
    private lazy var rightBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: "Mines left: 0", style: .plain, target: self, action: nil)
    }()
    private lazy var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: "Time: 0", style: .plain, target: self, action: nil)
    }()
    
    private var minesList = [false, true, false, false, false, true, true, false, false, false, false, true, false, true, false, false]
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addOne), userInfo: nil, repeats: true)
    }
    
    // how many squares our board has
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
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

