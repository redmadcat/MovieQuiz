import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - @IBOutlet
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Definition
    private let presenter = MovieQuizPresenter()
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
                
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureServices()
        configureUI()
        startOver()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        showActivityIndicator(false)
        guard let question else { return }
        currentQuestion = question
        let model = presenter.convert(model: question)
        show(quiz: model)
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
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
    
    private func configureServices() {
        showActivityIndicator(true)
        
        presenter.viewController = self
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }
    
    private func showActivityIndicator(_ isAnimating: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if (isAnimating) {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                self.blockButton(isEnabled: false)
            } else {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.blockButton(isEnabled: true)
            }
        }
    }
    
    private func showNetworkError(message: String) {
        showActivityIndicator(false)
        showAlert(title: "Ошибка",
                  message: message,
                  buttonText: "Попробовать еще раз",
                  completion: configureServices)
    }
    
    private func startOver() {
        presenter.resetQuestionIndex()
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
        
    private func show(quiz step: QuizStep) {
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }

    private func show(quiz result: QuizResults) {
        guard let statisticService else { return }

        let gameResult = GameResult(correct: correctAnswers, total: presenter.questionsAmount, date: Date())
        statisticService.store(result: gameResult)

        let totalGamesCount = statisticService.gamesCount
        let recordCorrect = statisticService.bestGame.correct
        let recordTotal = statisticService.bestGame.total
        let recordDate = statisticService.bestGame.date.dateTimeString
        let totalAccuracy = statisticService.totalAccuracy

        let message = """
            \(result.text)
            Количество сыгранных квизов: \(totalGamesCount)
            Рекорд: \(recordCorrect)/\(recordTotal) (\(recordDate))
            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
            """
        
        showAlert(title: result.title,
                  message: message,
                  buttonText: result.buttonText,
                  completion: startOver)
    }
    
    private func showAlert(title: String, message: String, buttonText: String, completion: @escaping () -> Void) {
        let quizAlert = QuizAlert(
            title: title,
            message: message,
            buttonText: buttonText,
            completion: completion)
                        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        alertPresenter.push(quizAlert: quizAlert)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1;
        }
                
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        showResultBorder(show: true)
        showActivityIndicator(true)
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            
            self.showResultBorder(show: false)
            self.showNextQuestionOrResults()
        }
    }
    
    private func blockButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
        
    private func showResultBorder(show: Bool) {
        previewImage.layer.borderWidth = show ? 8 : 0
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let model = QuizResults(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)",
                buttonText: "Сыграть ещё раз")
            
            show(quiz: model)
        } else {
            presenter.resetQuestionIndex()
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - @IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
}
