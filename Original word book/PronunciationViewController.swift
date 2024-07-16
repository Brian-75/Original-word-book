import UIKit
import Speech
import AVFoundation

class PronunciationViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let words = ["apple", "banana", "grape", "orange", "strawberry"]
    private var currentWord: String?
    private var results: [(word: String, recognizedText: String, isCorrect: Bool)] = []
    private var attemptCount = 0
    private let maxAttempts = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpeechRecognizer()
        displayRandomWord()
    }

    private func setupSpeechRecognizer() {
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                self.recordButton.isEnabled = authStatus == .authorized
            }
        }
    }

    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.setTitle("録音開始", for: .normal)
        } else {
            startRecording()
            recordButton.setTitle("録音停止", for: .normal)
        }
    }

    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object") }

        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false

            if let result = result {
                let recognizedText = result.bestTranscription.formattedString
                self.resultLabel.text = "Recognized text: \(recognizedText)"
                isFinal = result.isFinal
                if isFinal {
                    let isCorrect = recognizedText.lowercased() == self.currentWord?.lowercased()
                    self.results.append((word: self.currentWord ?? "", recognizedText: recognizedText, isCorrect: isCorrect))
                    self.attemptCount += 1

                    if self.attemptCount < self.maxAttempts {
                        self.displayRandomWord()
                    } else {
                        self.performSegue(withIdentifier: "showSpeakResults", sender: nil)
                    }
                }
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.recordButton.isEnabled = true
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }

        resultLabel.text = "録音中です…"
    }

    private func displayRandomWord() {
        currentWord = words.randomElement()
        wordLabel.text = currentWord
        resultLabel.text = ""
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSpeakResults" {
            let destinationVC = segue.destination as! SpeakResultViewController
            destinationVC.results = results
        }
    }
}

