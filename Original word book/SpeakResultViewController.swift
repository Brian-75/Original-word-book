import UIKit

class SpeakResultViewController: UIViewController {

    @IBOutlet weak var resultsTableView: UITableView!

    var results: [(word: String, recognizedText: String, isCorrect: Bool)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.dataSource = self
    }
}

extension SpeakResultViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        let result = results[indexPath.row]
        cell.textLabel?.text = "Word: \(result.word) - Recognized: \(result.recognizedText) - \(result.isCorrect ? "⭕️" : "❌")"
        return cell
    }
}

