import UIKit
import AVFoundation

class input_ViewController: UIViewController, AVSpeechSynthesizerDelegate {

    @IBOutlet var japanLabel: UILabel!
    @IBOutlet var englishLabel: UILabel!
    @IBOutlet var retryButton: UIButton!  // 追加：RetryボタンのIBOutlet
    @IBOutlet var topButton: UIButton!    // 追加：TopボタンのIBOutlet

    var wordArray: [Dictionary<String,String>] = []
    var readWords: Set<Int> = []
    let saveData = UserDefaults.standard
    var speechSynthesizer = AVSpeechSynthesizer()
    var isStopped = false

    override func viewDidLoad() {
        super.viewDidLoad()

        japanLabel.text = ""
        englishLabel.text = ""

        speechSynthesizer.delegate = self

        loadWordArray()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isStopped = false
        readWords.removeAll()
        showNextWord()
    }

    @IBAction func retryButtonTapped(_ sender: UIButton) {
        // 現在の単語の状態をリセットし、再実行
        readWords.removeAll()
        loadWordArray()
        isStopped = false
        englishLabel.text = ""
        japanLabel.text = ""
        showNextWord()
    }

    @IBAction func topButtonTapped(_ sender: UIButton) {
        // すべての動作を停止
        isStopped = true
        speechSynthesizer.stopSpeaking(at: .immediate)
        japanLabel.text = ""
        englishLabel.text = ""
        self.performSegue(withIdentifier: "toTop", sender: self)
    }

    func loadWordArray() {
        if let savedWords = saveData.array(forKey: "WORD") as? [Dictionary<String, String>] {
            wordArray = savedWords
            wordArray.shuffle()
        }
    }

    func showNextWord() {
        guard !isStopped else { return }
        
        if readWords.count >= wordArray.count {
            // 全ての単語が読み上げられた
            englishLabel.text = "Finished"
            japanLabel.text = ""
            return
        }

        var nextIndex: Int
        repeat {
            nextIndex = Int.random(in: 0..<wordArray.count)
        } while readWords.contains(nextIndex)

        readWords.insert(nextIndex)

        let currentWord = wordArray[nextIndex]
        englishLabel.text = ""
        japanLabel.text = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard !self.isStopped else { return }
            self.englishLabel.text = currentWord["english"]
            self.japanLabel.text = currentWord["Japanese"]
            self.speakText(currentWord["english"] ?? "", language: "en-US") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    guard !self.isStopped else { return }
                    self.speakText(currentWord["Japanese"] ?? "", language: "ja-JP") {
                        self.englishLabel.text = ""
                        self.japanLabel.text = ""
                        self.showNextWord()
                    }
                }
            }
        }
    }

    func speakText(_ text: String, language: String, completion: @escaping () -> Void) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)

        speechSynthesizer.speak(utterance)
        DispatchQueue.global().async {
            while self.speechSynthesizer.isSpeaking {
                usleep(100_000)
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
