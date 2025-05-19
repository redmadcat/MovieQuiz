//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Roman Yaschenkov on 24.04.2025.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    // MARK: - Definition
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    private weak var delegate: QuestionFactoryDelegate?
    
    /// Temporary exclude according to the recommendations from the lesson
    /*
    private let questions: [QuizQuestion] = QuizQuestion.mockQuestions
    */
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    // MARK: - QuestionFactoryProtocol
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            let value = (7...9).randomElement() ?? 0
            let text = "Рейтинг этого фильма больше чем \(value)?"
            let correctAnswer = rating > Float(value)
                                    
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.global().async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case.failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.didFailToLoadData(with: error)
                    }
                }
            }
        }
    }
}
