import UIKit

class SpurOfTheMomentResultsViewController: UIViewController {

    var questions: [(displayedWord: String, correspondingWord: String)] = []

    @IBOutlet weak var detailsTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var detailsText = ""
        for (index, question) in questions.enumerated() {
            detailsText += "Question \(index + 1):\n"
            detailsText += "Displayed: \(question.displayedWord)\n"
            detailsText += "Corresponding: \(question.correspondingWord)\n\n"
        }
        detailsTextView.text = detailsText
    }

    @IBAction func didTapRetryButton(){
        self.performSegue(withIdentifier: "toSpurOfThe", sender: self)
    
    }
    @IBAction func topButtonTapped(_ sender: UIButton) {
        // すべての動作を停止
        self.performSegue(withIdentifier: "toTop", sender: self)
    }
}
