import UIKit

class SpellingQuizViewController: UIViewController {
    
    var wordArray: [Dictionary<String, String>] = []
    var currentQuestionIndex = 0
    var score = 0
    var userAnswers: [(question: String, correctAnswer: String, userAnswer: String, isCorrect: Bool)] = []
    let totalQuestions = 5

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWords()
        generateQuestion()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentQuestionIndex == totalQuestions {
            // Quiz finished, reset the state for new start
            currentQuestionIndex = 0
            score = 0
            userAnswers.removeAll()
            generateQuestion()
        }
    }

    func loadWords() {
        if let savedWords = UserDefaults.standard.array(forKey: "WORD") as? [Dictionary<String, String>] {
            wordArray = savedWords
        }
    }

    func generateQuestion() {
        guard wordArray.count >= 1 else { return }

        // Select a random word for the question
        let randomIndex = Int.random(in: 0..<wordArray.count)
        let selectedWord = wordArray[randomIndex]
        
        questionLabel.text = selectedWord["Japanese"]
        answerTextField.text = ""
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard let userAnswer = answerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
              let correctAnswer = wordArray.first(where: { $0["Japanese"] == questionLabel.text })?["english"]?.lowercased() else { return }
        
        let isCorrect = userAnswer == correctAnswer
        if isCorrect {
            score += 1
        }

        userAnswers.append((question: questionLabel.text!, correctAnswer: correctAnswer, userAnswer: userAnswer, isCorrect: isCorrect))

        currentQuestionIndex += 1

        if currentQuestionIndex < totalQuestions {
            generateQuestion()
        } else {
            performSegue(withIdentifier: "showScore2", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showScore2" {
            let scoreVC = segue.destination as! ScoreViewController
            scoreVC.score = score
            scoreVC.totalQuestions = totalQuestions
            scoreVC.userAnswers = userAnswers
        }
    }
}
