//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Roman Yaschenkov on 25.04.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
