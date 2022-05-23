//
//  ViewController.swift
//  project5
//
//  Created by Илья Лехов on 18.05.2022.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    var errorTitle: String!
    var errorMessage: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["none word"]
        }
        
        startGame()
    }
    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func refreshGame() {
        startGame()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func showErrorMessage(title: String, message: String) {
        errorTitle = title
        errorMessage = message
    }
    
    func submit (_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    if isLongEnough(word: lowerAnswer) {
                        if isSameWord(word: lowerAnswer) {
                        usedWords.insert(lowerAnswer, at: 0)
                        
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        
                        return
                                } else {
                                    showErrorMessage(title: "This is the same word!", message: "You're trying to add the same word")
                                }
                            } else {
                                showErrorMessage(title: "Short word", message: "Please, add word that are more than 3 characters")
                        }
                    } else {
                    showErrorMessage(title: "Word not recognize", message: "You can't make them up!")
                }
            } else {
                showErrorMessage(title: "Word already used", message: "Need originality!")
            }
        } else {
            guard let title = title else {return}
            showErrorMessage(title: "Word not possible", message: "You can't spell that word from \(title.lowercased()).")
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange.init(location: 0, length: word.utf16.count)
        let missspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return missspelledRange.location == NSNotFound
    }
    
    func isLongEnough(word: String) -> Bool {
        if word.count < 3 {
            return false
        } else {
            return true
        }
    }
    
    func isSameWord(word: String) -> Bool {
        if word == title {
            return false
        } else {
            return true
        }
    }
}

