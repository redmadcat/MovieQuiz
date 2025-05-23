//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Roman Yaschenkov on 23.05.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
        
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStep {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        
        return QuizStep(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: questionNumber)
    }
    
    private func checkAnswer(answer: Bool) {
        guard let currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == answer)
    }
    
    func yesButtonClicked() {
        checkAnswer(answer: true)
    }
    
    func noButtonClicked() {
        checkAnswer(answer: false)
    }
}
