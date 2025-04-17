import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - @IBOutlet
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // MARK: - Definition
    private let questions: [QuizQuestion] = QuizQuestion.mockQuestions
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
                
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        startOver()
    }
    
    private func configureUI() {
        let labelsFont = UIFont.ysMedium20
        questionTitleLabel.font = labelsFont
        indexLabel.font = labelsFont
        questionLabel.font = .ysBold23
        noButton.titleLabel?.font = labelsFont
        yesButton.titleLabel?.font = labelsFont
    }
    
    private func startOver() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        if let firstQuestion = questions.first {
            let model = convert(model: firstQuestion)
            show(quiz: model)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStep {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questions.count)"
        
        return QuizStep(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: questionNumber)
    }
    
    private func show(quiz step: QuizStep) {
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResults) {
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
        blockButton(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showResultBorder(show: false)
            self.blockButton(isEnabled: true)
            self.showNextQuestionOrResults()
        }
    }
    
    private func blockButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func checkAnswer(answer: Bool) {
        if let question = questions[safe: currentQuestionIndex] {
            showAnswerResult(isCorrect: question.correctAnswer == answer)
        }
    }
    
    private func showResultBorder(show: Bool) {
        previewImage.layer.borderWidth = show ? 8 : 0
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let model = QuizResults(
                title: "Этот раунд окончен!",
                text: "Ваш результат \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть ещё раз")
            
            show(quiz: model)
        } else {
            currentQuestionIndex += 1
            
            if let nextQuestion = questions[safe: currentQuestionIndex] {
                let model = convert(model: nextQuestion)
                
                show(quiz: model)
            }
        }
    }
    
    // MARK: - @IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkAnswer(answer: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(answer: true)
    }
}
