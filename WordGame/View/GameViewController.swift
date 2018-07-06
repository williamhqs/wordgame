//
//  ViewController.swift
//  WordGame
//
//  Created by William Hu on 7/6/18.
//  Copyright © 2018 William Hu. All rights reserved.
//

import UIKit
class GameViewController: UIViewController {

    let viewModel = GameViewModel()
    var gridView = GridView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.gridView)
        
        viewModel.wordsLoaded = {
            self.gridView.sourceWord =
            self.viewModel.words.first!
        }
        viewModel.loadWords()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

