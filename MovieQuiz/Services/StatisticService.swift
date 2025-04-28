//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Roman Yaschenkov on 25.04.2025.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    // MARK: - Definition
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
        case correctAnswers
    }
                
    // MARK: - StatisticServiceProtocol
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            gamesCount > 0 ?
                (Double(correctAnswers) / Double(10 * gamesCount)) * 100 : 0
        }
    }
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    func store(result: GameResult) {
        correctAnswers += result.correct
        gamesCount += 1
        
        if result > bestGame {
            bestGame = result
        }
    }
}
