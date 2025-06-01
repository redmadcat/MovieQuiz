//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Roman Yaschenkov on 23.05.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter:  QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
        
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.showActivityIndicator(false)
        guard let question else { return }
        currentQuestion = question
        let model = convert(model: question)
        viewController?.show(quiz: model)
    }
        
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func makeResultsMessage() -> String {
        let gameResult = GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
        statisticService.store(result: gameResult)
                
        let totalGamesCount = statisticService.gamesCount
        let recordCorrect = statisticService.bestGame.correct
        let recordTotal = statisticService.bestGame.total
        let recordDate = statisticService.bestGame.date.dateTimeString
        let totalAccuracy = statisticService.totalAccuracy
        
        return """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(totalGamesCount)
            Рекорд: \(recordCorrect)/\(recordTotal) (\(recordDate))
            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
            """
    }
        
    func convert(model: QuizQuestion) -> QuizStep {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        
        return QuizStep(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: questionNumber)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)

        viewController?.showResultBorder(show: true, isCorrectAnswer: isCorrect)
        viewController?.showActivityIndicator(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }

            self.proceedToNextQuestionOrResults()
            viewController?.showResultBorder(show: false)
        }
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1;
        }
    }
    
    private func checkAnswer(answer: Bool) {
        guard let currentQuestion else { return }
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == answer)
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let model = QuizResults(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз")
            
            viewController?.show(quiz: model)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
        
    func yesButtonClicked() {
        checkAnswer(answer: true)
    }
    
    func noButtonClicked() {
        checkAnswer(answer: false)
    }
}
