import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - @IBOutlet
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Definition
    private var presenter: MovieQuizPresenter!
                
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureServices()
        configureUI()
    }

    // MARK: - MovieQuizViewControllerProtocol
    func show(quiz step: QuizStep) {
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }

    func show(quiz result: QuizResults) {
        let message = presenter.makeResultsMessage()
        
        showAlert(title: result.title,
                  message: message,
                  buttonText: result.buttonText,
                  completion: presenter.restartGame)
    }
    
    func showResultBorder(show: Bool, isCorrectAnswer: Bool = false) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        previewImage.layer.borderWidth = show ? 8 : 0
    }
    
    func showActivityIndicator(_ isAnimating: Bool) {
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
    
    func showNetworkError(message: String) {
        showActivityIndicator(false)
        showAlert(title: "Ошибка",
                  message: message,
                  buttonText: "Попробовать еще раз",
                  completion: configureServices)
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
        
        presenter = MovieQuizPresenter(viewController: self)
        presenter.restartGame()
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
    
    private func blockButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }

    // MARK: - @IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
}
