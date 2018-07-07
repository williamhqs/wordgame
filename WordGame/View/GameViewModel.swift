//
//  GameViewModel.swift
//  WordGame
//
//  Created by William Hu on 7/6/18.
//  Copyright © 2018 William Hu. All rights reserved.
//

import Foundation
class GameViewModel {
    let loadWordAPIManager = LoadWordAPIManager()
    var words = [Word]() {
        didSet {
            DispatchQueue.main.async {
                self.wordsLoaded?()
            }
        }
    }
    
    var wordsLoaded: (()->Void)?
    
    func loadWords() {
        loadWordAPIManager.startLoadWords { (words, error) in
            guard error == nil, let words = words else {
                //TODO: Deal with error
                return
            }
            self.words = words
        }
    }
}
