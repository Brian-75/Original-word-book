import UIKit

class ListTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    var wordArray: [Dictionary<String, String>] = []
    let saveData = UserDefaults.standard
    var redSheetView: UIView!
    var isRedSheetVisible = false
    var coveredFrame: CGRect = .zero
    var hiddenJapaneseIndices: [IndexPath] = []
    
    // 固定ボタンのプロパティ
    let fixedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("赤シート", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 赤シート関連のコードが実行されたかどうかを示すフラグ
    var isRedSheetSetup = false
    var swipeGesture: UIPanGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "cell")

        // 固定ボタンの設定
        setupFixedButton()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if saveData.array(forKey: "WORD") != nil {
            wordArray = saveData.array(forKey: "WORD") as! [Dictionary<String, String>]
        }
        tableView.reloadData()
    }

    // 赤シートビューの設定
    func setupRedSheetView() {
        redSheetView = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height))
        redSheetView.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        redSheetView.isHidden = true
        view.addSubview(redSheetView)
        view.addSubview(fixedButton)
    }

    // スワイプジェスチャーの設定
    func setupSwipeGestures() {
        swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture?.delegate = self
        if let swipeGesture = swipeGesture {
            view.addGestureRecognizer(swipeGesture)
        }
    }

    @objc func handleSwipe(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        switch sender.state {
        case .began:
            if !isRedSheetVisible {
                redSheetView.isHidden = false
                isRedSheetVisible = true
            }
        case .changed:
            if isRedSheetVisible {
                let newY = min(view.frame.height, max(view.frame.height - redSheetView.frame.height, redSheetView.frame.origin.y + translation.y))
                redSheetView.frame.origin.y = newY
                sender.setTranslation(.zero, in: view)
            }
        case .ended, .cancelled:
            coveredFrame = redSheetView.frame
            hideJapaneseUnderRedSheet()
        default:
            break
        }
    }

    func hideJapaneseUnderRedSheet() {
        hiddenJapaneseIndices.removeAll()
        
        let visibleCells = tableView.visibleCells.sorted {
            guard let indexPath1 = tableView.indexPath(for: $0),
                  let indexPath2 = tableView.indexPath(for: $1) else { return false }
            return indexPath1.row > indexPath2.row
        }

        for cell in visibleCells {
            if coveredFrame.intersects(cell.frame), let indexPath = tableView.indexPath(for: cell) {
                hiddenJapaneseIndices.append(indexPath)
            }
        }
        tableView.reloadData()
    }
    
    // 固定ボタンの設定
    func setupFixedButton() {
        view.addSubview(fixedButton)
        
        NSLayoutConstraint.activate([
            fixedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            fixedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 120),
            fixedButton.widthAnchor.constraint(equalToConstant: 70),
            fixedButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        fixedButton.addTarget(self, action: #selector(fixedButtonTapped), for: .touchUpInside)
    }
    
    @objc func fixedButtonTapped() {
        if isRedSheetSetup {
            // 赤シート関連の機能を無効化
            if let swipeGesture = swipeGesture {
                view.removeGestureRecognizer(swipeGesture)
            }
            redSheetView.isHidden = true
            isRedSheetVisible = false
            isRedSheetSetup = false
            hiddenJapaneseIndices.removeAll()
            tableView.reloadData()
            fixedButton.setTitle("赤シート", for: .normal)
        } else {
            // 赤シート関連の機能を有効化
            setupRedSheetView()
            setupSwipeGestures()
            isRedSheetSetup = true
            fixedButton.setTitle("単語一覧", for: .normal)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell

        let nowIndexPathDictionary = wordArray[indexPath.row]

        cell.englishLabel.text = nowIndexPathDictionary["english"]
        cell.japaneseLabel.text = hiddenJapaneseIndices.contains(indexPath) ? "" : nowIndexPathDictionary["Japanese"]

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            wordArray.remove(at: indexPath.row)
            saveData.set(wordArray, forKey: "WORD")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
