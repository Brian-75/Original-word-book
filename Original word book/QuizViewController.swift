import UIKit

class QuizViewController: UIViewController {
    
    var wordArray: [Dictionary<String, String>] = []
    var currentQuestionIndex = 0
    var score = 0
    let totalQuestions = 5

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var optionButton1: UIButton!
    @IBOutlet weak var optionButton2: UIButton!
    @IBOutlet weak var optionButton3: UIButton!

    // To store the questions and the user's answers
    var questions: [(question: String, answer: String, userAnswer: String, isCorrect: Bool)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Retrieve saved words
        if let savedWords = UserDefaults.standard.array(forKey: "WORD") as? [Dictionary<String, String>] {
            wordArray = savedWords
        }

        generateQuestion()
    }

    func generateQuestion() {
        guard wordArray.count >= 3 else { return }

        // Select a random word for the question
        let correctIndex = Int.random(in: 0..<wordArray.count)
        let correctWord = wordArray[correctIndex]
        
        questionLabel.text = correctWord["english"]

        // Select two incorrect options
        var options = wordArray.filter { $0["english"] != correctWord["english"] }
        options.shuffle()
        options = Array(options.prefix(2))
        
        // Add the correct option to the options list
        options.append(correctWord)
        options.shuffle()

        // Set the options to buttons
        optionButton1.setTitle(options[0]["Japanese"], for: .normal)
        optionButton1.tag = options[0] == correctWord ? 1 : 0

        optionButton2.setTitle(options[1]["Japanese"], for: .normal)
        optionButton2.tag = options[1] == correctWord ? 1 : 0

        optionButton3.setTitle(options[2]["Japanese"], for: .normal)
        optionButton3.tag = options[2] == correctWord ? 1 : 0
    }

    @IBAction func optionButtonTapped(_ sender: UIButton) {
        let question = questionLabel.text ?? ""
        let userAnswer = sender.currentTitle ?? ""
        let isCorrect = sender.tag == 1
        let correctAnswer = wordArray.first { $0["english"] == question }?["Japanese"] ?? ""

        questions.append((question: question, answer: correctAnswer, userAnswer: userAnswer, isCorrect: isCorrect))

        if isCorrect {
            score += 1
        }
        currentQuestionIndex += 1

        if currentQuestionIndex < totalQuestions {
            generateQuestion()
        } else {
            performSegue(withIdentifier: "showScore", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showScore" {
            let scoreVC = segue.destination as! ResultViewController
            scoreVC.score = score
            scoreVC.totalQuestions = totalQuestions
            scoreVC.questions = questions
        }
    }
}
