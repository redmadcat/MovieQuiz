//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Roman Yaschenkov on 25.04.2025.
//

import Foundation

struct GameResult: Equatable {
    let correct: Int
    let total: Int
    let date: Date
            
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
        
    // MARK: - Equatable
    static func > (lhs: GameResult, rhs: GameResult) -> Bool {
        return lhs.correct > rhs.correct
    }
}
