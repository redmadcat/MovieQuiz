import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - @IBOutlet
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // MARK: - Definition
    private let questionsAmount = 10
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
                
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFactory()
        configureUI()
        startOver()
        
#if DEBUG
        ClearUserDefaults()
#endif
    }
    
    // MARK: - UserDefaults clear
    private func ClearUserDefaults() {
        let allValues = UserDefaults.standard.dictionaryRepresentation()
        
        allValues.keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let model = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: model)
        }
    }
            
    // MARK: - Private functions
    private func configureUI() {
        let labelsFont = UIFont.ysMedium20
        questionTitleLabel.font = labelsFont
        indexLabel.font = labelsFont
        questionLabel.font = .ysBold23
        noButton.titleLabel?.font = labelsFont
        yesButton.titleLabel?.font = labelsFont
    }
    
    private func configureFactory() {
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
    }
    
    private func startOver() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func convert(model: QuizQuestion) -> QuizStep {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        
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
        let quizAlert = QuizAlert(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: self.startOver)
                        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        alertPresenter.push(quizAlert: quizAlert)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1;
        }
                
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        showResultBorder(show: true)
        blockButton(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
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
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == answer)
    }
    
    private func showResultBorder(show: Bool) {
        previewImage.layer.borderWidth = show ? 8 : 0
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let gameResult = GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
            statisticService.store(result: gameResult)
            
            let totalGamesCount = statisticService.gamesCount
            let recordCorrect = statisticService.bestGame.correct
            let recordTotal = statisticService.bestGame.total
            let recordDate = statisticService.bestGame.date.dateTimeString
            let totalAccuracy = statisticService.totalAccuracy
            
            let model = QuizResults(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)\n" +
                      "Количество сыгранных квизов: \(totalGamesCount)\n" +
                      "Рекорд: \(recordCorrect)/\(recordTotal) " + "(\(recordDate))\n" +
                      "Средняя точность: \(String(format: "%.2f", totalAccuracy))%",
                buttonText: "Сыграть ещё раз")
            
            show(quiz: model)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
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
