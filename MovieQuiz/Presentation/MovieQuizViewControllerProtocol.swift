//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Roman Yaschenkov on 01.06.2025.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStep)

    func show(quiz result: QuizResults)
    
    func showResultBorder(show: Bool, isCorrectAnswer: Bool)
    
    func showActivityIndicator(_ isAnimating: Bool)
    
    func showNetworkError(message: String)
}
