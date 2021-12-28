//
//  ViewController.swift
//  ticTacToeDemo
//
//  Created by bayareahank on 12/27/21.
//

import UIKit

let SquareLength = 3    // Square length, can be adjusted accordingly.

class ViewController: UIViewController {
    let saveFileName = "ticTacToeMoves.json"

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var winnerImageView: UIImageView!
    @IBOutlet var resetButton: UIButton!
    
    var steps = 0   // even for first player to move, odd for second.
    var stateData = [State](repeating: .none, count: SquareLength * SquareLength)
    var board: [[State]] {
        get {
            var values: [[State]] = Array(repeating: Array(repeating: .none, count: SquareLength), count: SquareLength)
            
            for i in 0..<SquareLength {
                for j in 0..<SquareLength {
                    values[i][j] = stateData[i * SquareLength + j]
                }
            }
            return values
        }
        set {
            for i in 0..<SquareLength {
                for j in 0..<SquareLength {
                    stateData[i * SquareLength + j] = newValue[i][j]
                }
            }
        }
    }
    // make board calculatd values of actual data, more comprehensible version
    
    var movesUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // A player makes a move, change state accordingly.
    @IBAction func doMove(_ sender: UIButton) {
        let buttonPosition : CGPoint = sender.convert(CGPoint.zero, to: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: buttonPosition) else {
            print ("Button outside of collectionView")
            return
        }
        
        if stateData[indexPath.item] != .none {
            print ("Cannot change made move")
            return
        }
        
        // Which player is on the move
        if steps % 2 == 0 {
            stateData[indexPath.item] = .first
        } else {
            stateData[indexPath.item] = .second
        }
        collectionView.reloadItems(at: [indexPath])
        
        if checkWin(indexPath.item) {
            showWinner()
        } else {
            steps += 1
            saveData()  // save each step, just like playing over the internet.
        }
    }
    
    @IBAction func resetGame(_ sender: UIButton) {
        resetData()
    }
    
    // Show the win sign, then clear the board.
    private func showWinner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            [weak self] in
            self?.winnerImageView.isHidden = false
            self?.resetButton.isHidden = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            [weak self] in
            
            self?.resetData()
        }
    }
    
    private func setup() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = makeLayout()
        
        winnerImageView.isHidden = true
        resetButton.titleLabel?.font = .boldSystemFont(ofSize: 30)
        // Not sure why changing it from storyboard doesn't work 
        
        guard let documentDirectory =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
        }
        movesUrl = documentDirectory.appendingPathComponent(saveFileName)
            
        // If exists a previously saved data file, load.
        if let movesUrl = movesUrl {
            if FileManager.default.fileExists(atPath: movesUrl.path) {
                loadData()
            } else {
                resetData()
            }
        } else {
            // We can still play even if file system failed.
            resetData()
        }
    }
    
    // Use compositional layout for collectionView
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(SquareLength)), heightDimension: .fractionalHeight(1.0 / 1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0/CGFloat(SquareLength)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func resetData() {
        stateData = [State](repeating: .none, count: SquareLength * SquareLength)
        
        collectionView.reloadData()     // clear board.
        steps = 0
        
        winnerImageView.isHidden = true
        resetButton.isHidden = false
        
        saveData()  // clear saved also.
    }
    
    // load state from file
    private func loadData() {
        guard let movesUrl = movesUrl else {
            return
        }
        
        do {
            let data = try Data(contentsOf: movesUrl, options: [])
            let moves = try JSONDecoder().decode([Move].self, from: data)
            
            for move in moves {
                board[move.x][move.y] = move.state
                // print ("\(move.x) \(move.y) \(move.state)")
                if move.state != .none {
                    steps += 1
                }
            }
        } catch {
            print ("Retriving moves failed \(error.localizedDescription)")
        }
    }
    
    // Save current state to file
    private func saveData() {
        var moves = [Move]()
        
        // convert board value to moves.
        for i in 0..<3 {
            for j in 0..<3 {
                let move = Move(x: i, y: j, state: board[i][j])
                moves.append(move)
            }
        }
        
        guard let encodedData = try? JSONEncoder().encode(moves) else {
            return
        }
        
        guard let movesUrl = movesUrl else {
            return
        }

        do {
            try encodedData.write(to: movesUrl)
                
        } catch {
            print ("Saving move failed \(error.localizedDescription)")
        }
    }
    
    // Whether somebody wins
    func checkWin(_ index: Int) -> Bool {
        let x = index / SquareLength
        let y = index % SquareLength
        
        var foundWin = true
        let state = board[x][y]
        
        /*
        print ("current: \(x) \(y) \(board[x][y])")
        for i in 0..<SquareLength {
            for j in 0..<SquareLength {
                print ("\(i) \(j) \(board[i][j])")
            }
        }
        */
        
        // check same column
        for j in 0..<SquareLength {
            if board[x][j] != state {
                foundWin = false
                break
            }
        }
        if foundWin == true {
            print ("Same column equal ...")
            return true
        }
        
        // check same line
        foundWin = true
        for i in 0..<SquareLength {
            if board[i][y] != state {
                foundWin = false
                break
            }
        }
        if foundWin == true {
            print ("Same line equal ...")
            return true
        }
        
        // print ("Checking diagonal ...")
        // diagonal
        foundWin = true
        if x == y {
            for i in 0..<SquareLength {
                if board[i][i] != state {
                    foundWin = false
                    break
                }
            }
        } else {
            foundWin = false
        }
        if foundWin == true {
            print ("Diagonal equal ... ")
            return true
        }
        
        // print ("Checking reverse diagnonal ... ")
        // the other diagonal
        foundWin = true
        if x + y == SquareLength - 1 {
            for i in 0..<SquareLength {
                if board[SquareLength - i - 1][i] != state {
                    foundWin = false
                    break
                }
            }
        } else {
            foundWin = false
        }
        if foundWin == true {
            print ("Reverse diagonal equal ... ")
        }

        return foundWin
    }

}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stateData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoveCollectionViewCell.cellId, for: indexPath) as! MoveCollectionViewCell
        
        cell.configure(stateData[indexPath.item])
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        // Once a move is made, not allowed to change.
        if stateData[indexPath.item] == .none {
            return true
        } else {
            return false
        }
    }
}

