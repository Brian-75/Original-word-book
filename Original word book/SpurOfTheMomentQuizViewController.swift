import UIKit

class SpurOfTheMomentQuizViewController: UIViewController {
    
    var wordArray: [Dictionary<String, String>] = []
    var currentQuestionIndex = 0
    let totalQuestions = 5
    var questions: [(displayedWord: String, correspondingWord: String)] = []
    var timer: Timer?
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet var Label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWords()
        displayNextQuestion()
    }

    func loadWords() {
        if let savedWords = UserDefaults.standard.array(forKey: "WORD") as? [Dictionary<String, String>] {
            wordArray = savedWords
        }
    }

    @objc func displayNextQuestion() {
        guard wordArray.count >= 1 else { return }

        // Select a random word for the question
        let randomIndex = Int.random(in: 0..<wordArray.count)
        let selectedWord = wordArray[randomIndex]
        
        // Randomly decide to show "Japanese" or "English"
        if Bool.random() {
            questionLabel.text = selectedWord["Japanese"]
            questions.append((displayedWord: selectedWord["Japanese"]!, correspondingWord: selectedWord["english"]!))
        } else {
            questionLabel.text = selectedWord["english"]
            questions.append((displayedWord: selectedWord["english"]!, correspondingWord: selectedWord["Japanese"]!))
        }

        currentQuestionIndex += 1

        if currentQuestionIndex < totalQuestions {
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(displayNextQuestion), userInfo: nil, repeats: false)
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(showResults), userInfo: nil, repeats: false)
        }
    }

    @objc func showResults() {
        performSegue(withIdentifier: "showResults", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResults" {
            let resultsVC = segue.destination as! SpurOfTheMomentResultsViewController

            resultsVC.questions = questions
        }
    }
}
