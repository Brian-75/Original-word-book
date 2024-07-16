import UIKit

class ScoreViewController: UIViewController {

    var score: Int = 0
    var totalQuestions: Int = 0
    var userAnswers: [(question: String, correctAnswer: String, userAnswer: String, isCorrect: Bool)] = []

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var resultsTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "Your score: \(score) out of \(totalQuestions)"
        displayResults()
    }

    @IBAction func didTapRetryButton(){
        self.performSegue(withIdentifier: "toSpelling", sender: self)
    }

    @IBAction func topButtonTapped(_ sender: UIButton) {
        // すべての動作を停止
        self.performSegue(withIdentifier: "toTop", sender: self)
    }

    func displayResults() {
        var resultsText = ""
        
        for answer in userAnswers {
            let resultSymbol = answer.isCorrect ? "⭕️" : "❌"
            resultsText += "Japanese: \(answer.question)\n"
            resultsText += "Your Answer: \(answer.userAnswer) \(resultSymbol)\n"
            resultsText += "Correct Answer: \(answer.correctAnswer)\n\n"
        }
        
        resultsTextView.text = resultsText
    }
}
