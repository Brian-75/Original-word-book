//
//  AddViewController.swift
//  Original word book
//
//  Created by 植田英介 on 2024/05/14.
//

import UIKit

class AddViewController: UIViewController {
    
    @IBOutlet var englishTextField: UITextField!
    @IBOutlet var japaneseTextField: UITextField!
    
    var wordArray: [Dictionary<String,String>] = []
    
    let saveData = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if saveData.array(forKey: "WORD") != nil {
            wordArray = saveData.array(forKey: "WORD") as! [Dictionary<String,String>]
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func reset() {
        let alert = UIAlertController(title: "最終確認", message: "本当に消して良いですか？", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            
            self.performSegue(withIdentifier: "totop", sender: self)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveWord() {
        
        let english = englishTextField.text ?? ""
        let japanese = japaneseTextField.text ?? ""
        
    
        
        if english.isEmpty || japanese.isEmpty {
            let alert = UIAlertController(
                title: "保存できません",
                message:"単語を入力してください",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler:nil
            ))
            
            present(alert, animated: true, completion: nil)
        } else {
            
            let wordDictionary = ["english": englishTextField.text!, "Japanese": japaneseTextField.text!]
            
            wordArray.append(wordDictionary)
            saveData.set(wordArray, forKey: "WORD")
            
            let alert = UIAlertController(
                title: "保存完了",
                message: "単語の登録が完了しました",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil
            ))
            
            present(alert, animated: true, completion: nil)
            englishTextField.text = ""
            japaneseTextField.text = ""
        }
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
}
