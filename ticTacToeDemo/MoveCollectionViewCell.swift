//
//  MoveCollectionViewCell.swift
//  ticTacToeDemo
//
//  Created by bayareahank on 12/27/21.
//

import UIKit

class MoveCollectionViewCell: UICollectionViewCell {
    static let cellId = "moveCell"
    
    @IBOutlet var button: UIButton!
    
    // Once a non-blank state is set, it shouldn't be changed. We leave that logic to VC.
    func configure(_ state: State) {
        switch state {
        case .none:
            button.setImage(UIImage(named: "blankLine"), for: .normal)
        case .first:
            button.setImage(UIImage(named: "circled"), for: .normal)
        case .second:
            button.setImage(UIImage(named: "crossMark"), for: .normal)
        }
        button.contentMode = .center
        button.imageView?.contentMode = .scaleAspectFill
    }
}
