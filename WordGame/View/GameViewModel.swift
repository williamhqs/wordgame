//
//  GameViewModel.swift
//  WordGame
//
//  Created by William Hu on 7/6/18.
//  Copyright © 2018 William Hu. All rights reserved.
//

import Foundation
class GameViewModel {
    var words = [Word]() {
        didSet {
            DispatchQueue.main.async {
                self.wordsLoaded?()
            }
        }
    }
    
    var wordsLoaded: (()->Void)?
    
    func loadWords() {
        let session = URLSession(configuration: .default)
        let req = URLRequest(url: URL(string: "https://s3.amazonaws.com/duolingo-data/s3/js2/find_challenges.txt")!)
        
        session.dataTask(with: req) { (data, response, error) in
            guard error == nil else {
                print(error)
                return
            }
            guard let responseTxtData = data else {
                print("No data")
                return
            }
            guard let responseString = String(data: responseTxtData, encoding: .utf8) else {
                print("Convert to plain text error")
                return
            }
            let s = responseString.components(separatedBy: .newlines)
            
            s.compactMap { $0.data(using: .utf8)}.forEach({ (a) in
                do {
                    let f = try JSONDecoder().decode(Word.self, from: a)
                    self.words.append(f)
                } catch {
                    print(error)
                }
            })
       }.resume()
    }
}
