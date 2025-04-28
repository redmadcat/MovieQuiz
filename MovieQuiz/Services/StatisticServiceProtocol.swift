//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Roman Yaschenkov on 25.04.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(result: GameResult)
}
