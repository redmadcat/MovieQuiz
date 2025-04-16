import UIKit

extension Array {
    func getSafe(at index: Int) -> Element? {
        let isValidIndex = index >= 0 && index < count
        return isValidIndex ? self[index] : nil
    }
}

final class MovieQuizViewController: UIViewController {
    // MARK: - @IBOutlet
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // MARK: - Definintion
    private let ysMedium20: UIFont? = {
        UIFont(name: "YSDisplay-Medium", size: 20.0)
    }()
    
    private let ysBold23: UIFont? = {
        UIFont(name: "YSDisplay-Bold", size: 23.0)
    }()
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    // MARK: - Mock data
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
            
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionTitleLabel.font = ysMedium20
        questionLabel.font = ysBold23
        indexLabel.font = ysMedium20
        noButton.titleLabel?.font = ysMedium20
        yesButton.titleLabel?.font = ysMedium20
          
        startOver()
    }
    
    private func startOver()
    {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        if let firstQuestion = questions.first {
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questions.count)"
        
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: questionNumber)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.startOver()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1;
        }
                
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        showResultBorder(show: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showResultBorder(show: false)
            self.showNextQuestionOrResults()
        }
    }
    
    private func checkAnswer(answer: Bool) {
        if let question = questions.getSafe(at: currentQuestionIndex) {
            showAnswerResult(isCorrect: question.correctAnswer == answer)
        }
    }
    
    private func showResultBorder(show: Bool) {
        previewImage.layer.borderWidth = show ? 8 : 0
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть ещё раз")
            
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            if let nextQuestion = questions.getSafe(at: currentQuestionIndex) {
                let viewModel = convert(model: nextQuestion)
                
                show(quiz: viewModel)
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkAnswer(answer: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(answer: true)
    }
}
