//
//  GridViewModel.swift
//  WordGame
//
//  Created by William Hu on 7/6/18.
//  Copyright © 2018 William Hu. All rights reserved.
//

import Foundation

enum WordCorrect {
    case not
    case part
    case all
}

final class GridViewModel {
    
    private var currentIndex: Int = -1
    private var correctWords = [String]()
    var thisTimeCorrect = false
    var selectedCharacterPoints = [String]()
    
    var words = [Word]() {
        didSet {
            next()
        }
    }
    
    var newSourceWord: ((Word) -> Void)?
    var nextWordLoad: ((Word) -> Void)?
    var currentCorrectTargeWord: ((String) -> Void)?
    
    // MARK: - Private Methods
    private func generateSelectedWordKey(_ position:(Int, Int)) -> String {
        return String(position.0)+","+String(position.1)+","
    }
    
    private func generateSelectedKey() -> String? {
        var selectedWordKey = selectedCharacterPoints.reduce("", + )
        guard !selectedWordKey.isEmpty else {
            return .none
        }
        selectedWordKey.removeLast()
        return selectedWordKey
    }
    
    private func generateSelectedWord(by selectedWordValue: String) -> [String:String]? {
        guard let selectedWordKey = generateSelectedKey() else {
            return .none
        }
        return [selectedWordKey:selectedWordValue]
    }
    
    
    private func addSelectedNodePoints(_ locationString: String) {
        if !selectedCharacterPoints.contains(locationString) {
            selectedCharacterPoints.append(locationString)
        }
    }
    
    // MARK: - Public Methods
    func addNodePosition(_ position: (Int, Int)) {
        let locationString = generateSelectedWordKey(position)
        addSelectedNodePoints(locationString)
    }
    
    func checkSelectedWordCorrect(_ selectedWordValue: String) -> WordCorrect{
        let currectWord = words[currentIndex]
        let key = generateSelectedKey()
        if currectWord.word_locations[key!] == selectedWordValue {
            if !correctWords.contains(selectedWordValue) {
                thisTimeCorrect = true
                correctWords.append(selectedWordValue)
            } else {
                thisTimeCorrect = false
            }
        } else {
            thisTimeCorrect = false
            return correctWords.count > 0 ? .part : .not
        }
        
        if correctWords.count == currectWord.word_locations.count {
            correctWords.removeAll()
            return .all
        } else {
            return .part
        }
    }
    
    func next() {
        currentIndex += 1
        if currentIndex >= words.count || currentIndex == -1 {
            currentIndex = 0
        }
        newSourceWord?(words[currentIndex])
        nextWordLoad?(words[currentIndex])
        thisTimeCorrect = false
    }
    
    func showCorrectTargetWord() {
        if let wordString = words[currentIndex].word_locations.values.first {
            currentCorrectTargeWord?(wordString)
        }
    }
    
    func showNextSourceWord() {
        if let wordString = words[currentIndex].word_locations.values.first {
            currentCorrectTargeWord?(wordString)
        }
    }
    
}
