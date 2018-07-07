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
    private var checkedWords1 = [String]()
    var isCorrect: WordCorrect = .not
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
    
    func generateSelectedWordKey(_ position:(Int, Int)) -> String {
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
    
    func addNodePosition(_ position: (Int, Int)) {
        let locationString = generateSelectedWordKey(position)
        addSelectedNodePoints(locationString)
    }
    
    func generateSelectedWord(by selectedWordValue: String) -> [String:String]? {
        guard let selectedWordKey = generateSelectedKey() else {
            return .none
        }
        return [selectedWordKey:selectedWordValue]
    }
    
    func checkSelectedWordCorrect(_ selectedWordValue: String) -> WordCorrect{
        let currectWord = words[currentIndex]
        let key = generateSelectedKey()
        if currectWord.word_locations[key!] == selectedWordValue {
            if !checkedWords1.contains(selectedWordValue) {
                thisTimeCorrect = true
                checkedWords1.append(selectedWordValue)
            } else {
                thisTimeCorrect = false
            }
        } else {
            if checkedWords1.count > 0 {
                return .part
            }
            return .not
        }
        if checkedWords1.count == currectWord.word_locations.count {
            checkedWords1.removeAll()
            isCorrect = .all
        } else {
            isCorrect = .part
        }
        return isCorrect
    }
    
    private func addSelectedNodePoints(_ locationString: String) {
        if !selectedCharacterPoints.contains(locationString) {
            selectedCharacterPoints.append(locationString)
        }
    }
    
    func next() {
        currentIndex += 1
        guard currentIndex < words.count || currentIndex == -1 else {
            currentIndex = 0
            return
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
