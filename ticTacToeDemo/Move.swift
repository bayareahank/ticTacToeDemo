//
//  Move.swift
//  ticTacToeDemo
//
//  Created by bayareahank on 12/27/21.
//

import Foundation

enum State: Int, Codable {
    case none = 0
    case first = 1
    case second = 2
}

// To save board state to JSON. 
struct Move: Codable {
    let x: Int
    let y: Int
    
    var state: State
}
