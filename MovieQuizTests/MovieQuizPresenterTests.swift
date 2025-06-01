//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Roman Yaschenkov on 01.06.2025.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertMode() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let model = sut.convert(model: question)
        
        XCTAssertNotNil(model.image)
        XCTAssertEqual(model.question, "Question Text")
        XCTAssertEqual(model.questionNumber, "1/10")
    }
}
