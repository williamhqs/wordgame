//
//  ViewController.swift
//  WordGame
//
//  Created by William Hu on 7/6/18.
//  Copyright © 2018 William Hu. All rights reserved.
//

import UIKit
class GameViewController: UIViewController {

    @IBOutlet weak var sourceLanguage: UILabel!
    @IBOutlet weak var targetLanguage: UILabel!
    @IBOutlet weak var sourceWord: UILabel!
    @IBOutlet weak var targetWord: UILabel!
    
    let viewModel = GameViewModel()
    var gridView = GridView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.gridView)
        
        viewModel.wordsLoaded = {
            self.gridView.viewModel.words = self.viewModel.words
            self.configureWordInformations(word: self.gridView.sourceWord)
        }
        viewModel.loadWords()
        
        gridView.viewModel.nextWordLoad = { nextWord in
            self.configureWordInformations(word: nextWord)
        }
        
        gridView.viewModel.currentCorrectTargeWord = { targetWord in
            self.configureTargetWord(word: targetWord)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private Methods
    private func configureWordInformations(word: Word?) {
        self.sourceLanguage.text = word?.source_language
        self.targetLanguage.text = word?.target_language
        self.sourceWord.text = word?.word
        
        self.sourceLanguage.text = word?.word_locations.values.reduce("", { $0 + "|" + $1} )
    }
    
    private func configureTargetWord(word: String) {
        UIView.animate(withDuration: 0.5, animations: {
            self.targetWord.text = word
            self.targetWord.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        },  completion: { finished in
            self.targetWord.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.targetWord.text = ""
        })
    }
}

