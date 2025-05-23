//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Roman Yaschenkov on 25.04.2025.
//

import UIKit

final class AlertPresenter {
    weak var delegate: UIViewController?
        
    func push(quizAlert: QuizAlert) {
        let alert = UIAlertController(
            title: quizAlert.title,
            message: quizAlert.message,
            preferredStyle: .alert)
        
        /// For Unit Tests purpose
        alert.view.accessibilityIdentifier = "Alert"

        let action = UIAlertAction(title: quizAlert.buttonText, style: .default) { _ in
            quizAlert.completion()
        }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
