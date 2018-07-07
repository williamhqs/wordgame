//
//  Word.swift
//  WordGame
//
//  Created by William Hu on 7/6/18.
//  Copyright © 2018 William Hu. All rights reserved.
//

import Foundation

struct Word {
    let sourceLanguage: String
    let word: String
    let wordLocations: [String: String]
    let targetLanguage: String
    let characterGrid: [[String]]
    
    private enum CodingKeys: String, CodingKey {
        case sourceLanguage = "source_language"
        case wordLocations = "word_locations"
        case targetLanguage = "target_language"
        case characterGrid = "character_grid"
        case word = "word"
    }
}

extension Word: Codable {
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        characterGrid = try values.decode([[String]].self, forKey:.characterGrid)
        targetLanguage = try values.decode(String.self, forKey:.targetLanguage)
        wordLocations = try values.decode([String:String].self, forKey:.wordLocations)
        sourceLanguage = try values.decode(String.self, forKey:.sourceLanguage)
        word = try values.decode(String.self, forKey:.word)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sourceLanguage, forKey: .sourceLanguage)
        try container.encode(targetLanguage, forKey: .targetLanguage)
        try container.encode(wordLocations, forKey: .wordLocations)
        try container.encode(characterGrid, forKey: .characterGrid)
        try container.encode(word, forKey: .word)
    }

}
