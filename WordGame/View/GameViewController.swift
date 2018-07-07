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
    @IBOutlet weak var gridView: GridView!
    
    let viewModel = GameViewModel()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.loadWords()
        
        gridView.viewModel.nextWordLoad = { nextWord in
            self.configureWordInformations(word: nextWord)
        }
        
        gridView.viewModel.currentCorrectTargeWord = { targetWord in
            self.configureTargetWord(word: targetWord)
        }
        
        viewModel.wordsLoaded = {
            self.gridView.viewModel.words = self.viewModel.words
            self.configureWordInformations(word: self.gridView.sourceWord)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private Methods
    private func configureWordInformations(word: Word?) {
        self.sourceLanguage.text = word?.sourceLanguage
        self.targetLanguage.text = word?.targetLanguage
        self.sourceWord.text = word?.word
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

