//
//  Word.swift
//  WordGame
//
//  Created by William Hu on 7/6/18.
//  Copyright © 2018 William Hu. All rights reserved.
//

import Foundation
struct Word: Codable {//}, CustomStringConvertible {
    let source_language: String
    let word: String
    let word_locations: [String: String]
    let target_language: String
    let character_grid: [[String]]
    
    //    var description: String {
    //        return
    //    }
}
