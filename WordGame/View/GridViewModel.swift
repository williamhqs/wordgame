//
//  GridViewModel.swift
//  WordGame
//
//  Created by William Hu on 7/6/18.
//  Copyright © 2018 William Hu. All rights reserved.
//

import Foundation
final class GridViewModel {
    
    var selectedCharacterPoints = [String]()
    
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
    
    private func addSelectedNodePoints(_ locationString: String) {
        if !selectedCharacterPoints.contains(locationString) {
            selectedCharacterPoints.append(locationString)
        }
    }
    
}
