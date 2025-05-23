//
//  StubNetworkClient.swift
//  MovieQuizTests
//
//  Created by Roman Yaschenkov on 22.05.2025.
//

import Foundation
@testable import MovieQuiz

struct StubNetworkClient: NetworkRouting {
    enum TestError: Error {
        case test
    }

    let emulateError: Bool

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if emulateError {
            handler(.failure(TestError.test))
        } else {
            handler(.success(ResponseMock.expectedResponse))
        }
    }
}
