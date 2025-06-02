//
//  MovieQuizViewControllerMock.swift
//  MovieQuizTests
//
//  Created by Roman Yaschenkov on 01.06.2025.
//

@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStep) {
        
    }
    
    func show(quiz result: MovieQuiz.QuizResults) {
        
    }
    
    func showResultBorder(show: Bool, isCorrectAnswer: Bool) {
        
    }
    
    func showActivityIndicator(_ isAnimating: Bool) {
        
    }
    
    func showNetworkError(message: String) {
        
    }
}
