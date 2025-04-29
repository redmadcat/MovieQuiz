//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Roman Yaschenkov on 25.04.2025.
//

import Foundation

struct GameResult: Comparable {
    let correct: Int
    let total: Int
    let date: Date
    
    // MARK: - Comparable
    static func < (lhs: GameResult, rhs: GameResult) -> Bool {
        lhs.correct < rhs.correct
    }
}

