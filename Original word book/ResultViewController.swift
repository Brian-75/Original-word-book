import UIKit

class ResultViewController: UIViewController {

    var score: Int = 0
    var totalQuestions: Int = 0
    var questions: [(question: String, answer: String, userAnswer: String, isCorrect: Bool)] = []

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var resultTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scoreLabel.text = "Your score: \(score) out of \(totalQuestions)"
        displayResults()
    }

    func displayResults() {
        var resultText = ""
        for (index, question) in questions.enumerated() {
            let mark = question.isCorrect ? "⭕️" : "❌"
            resultText += "Q\(index + 1): \(question.question) - \(question.answer)\nYour answer: \(question.userAnswer) \(mark)\n\n"
        }
        resultTextView.text = resultText
    }

    @IBAction func didTapRetryButton(){
        self.performSegue(withIdentifier: "toQuiz", sender: self)
    }
    
    @IBAction func topButtonTapped(_ sender: UIButton) {
        // すべての動作を停止
        self.performSegue(withIdentifier: "toTop", sender: self)
    }
}
