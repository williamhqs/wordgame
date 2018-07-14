//
//  LoadWordAPIManager.swift
//  WordGame
//
//  Created by 胡秋实 on 7/7/2018.
//  Copyright © 2018 William Hu. All rights reserved.
//

import Foundation

struct LoadWordAPIManager {
    func startLoadWords(completion: @escaping ([Word]?, NetworkError?)-> Void) {
        let session = URLSession(configuration: .default)
        let req = URLRequest(url: URL(string: "")!)
        session.dataTask(with: req) { (data, response, error) in
            guard error == nil else {
                completion(.none, .error1)
                return
            }
            guard let responseTxtData = data else {
                completion(.none, .error2)
                return
            }
            guard let responseString = String(data: responseTxtData, encoding: .utf8) else {
                completion(.none, .error2)
                return
            }
            let s = responseString.components(separatedBy: .newlines)
            
            let words = s.compactMap { $0.data(using: .utf8)}.map { (wordData) -> Word? in
                do {
                    return try JSONDecoder().decode(Word.self, from: wordData)
                } catch {
                    return .none
                }
                }.compactMap{$0}
            words.count == 0 ? completion(.none, .noData) : completion(words, .none)
        }.resume()
    }
}
