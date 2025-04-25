//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Roman Yaschenkov on 24.04.2025.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let questions: [QuizQuestion] = QuizQuestion.mockQuestions
    weak var delegate: QuestionFactoryDelegate?
    
    // MARK: - QuestionFactoryProtocol
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
}
