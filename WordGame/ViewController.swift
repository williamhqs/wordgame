//
//  ViewController.swift
//  WordGame
//
//  Created by William Hu on 7/6/18.
//  Copyright © 2018 William Hu. All rights reserved.
//

import UIKit

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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let session = URLSession(configuration: .default)
        let req = URLRequest(url: URL(string: "https://s3.amazonaws.com/duolingo-data/s3/js2/find_challenges.txt")!)
        var array = [Word]()
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
                    array.append(f)
                    
                    
                } catch {
                    print(error)
                }
            })
            
            print(array.first!)
            
            DispatchQueue.main.async {
                self.drawGrid(array.first!)
            }
            
        }.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var gridView = UIView()
    var width: CGFloat = 0
    var labels = [[UILabel]]()
    var targetWord: Word?
    func drawGrid(_ word: Word) {
        targetWord = word
        width = UIScreen.main.bounds.width/CGFloat(word.character_grid.count)
        gridView.frame = CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: CGFloat(word.character_grid.count) * width)
        
        gridView.backgroundColor = UIColor.green
        self.view.addSubview(gridView)
        
        word.character_grid.enumerated().forEach { (yOffset, element) in
            var la = [UILabel]()
            element.enumerated().forEach({ (xOffset, element) in
                let b = UILabel(frame: CGRect(x: CGFloat(xOffset) * width, y: CGFloat(yOffset) * width, width: width, height: width))
                b.backgroundColor = UIColor.red
                b.text = element
                la.append(b)
                gridView.addSubview(b)
            })
            labels.append(la)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first, touch.view == gridView else {
            return
        }
        
        let location = touch.location(in: gridView)
        print(location)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first, touch.view == gridView else {
            return
        }
        
        let location = touch.location(in: gridView)
//        let previousLocation = touch.previousLocation(in: gridView)
        let x = Int((location.x / width).rounded(.down))
        let y = Int((location.y / width).rounded(.down))
        
        let l = labels[y][x]
        print("\(x)--\(y)--\(l.text)")
        l.backgroundColor = UIColor.blue
        if !selected.contains(l) {
            selected.append(l)
        }
        let locationString = String(x)+","+String(y)+","
        if !points.contains(locationString) {
            points.append(locationString)
        }
        
        
    }
    var selected = [UILabel]()
    var points = [String]()
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(selected.count)
        print(targetWord!.word_locations)
        var finalKey = points.reduce("", + )
        
//        let finalValue = selected.reduce("", { $0 + $1.text!})
        let finalValue = selected.compactMap{$0.text}.reduce("", + )
        print(finalValue)
        if !finalKey.isEmpty {
            finalKey.removeLast()
        }
        
        print([finalKey : finalValue])
        if [finalKey : finalValue] == targetWord!.word_locations {
            print("Correct word: Next")
        }
        points.removeAll()
        UIView.animate(withDuration: 1.0, delay: 0, options: .allowUserInteraction, animations: {
            self.selected.forEach {
                $0.backgroundColor = UIColor.red
            }
        }, completion: { finished in
            if finished {
                self.selected.removeAll()
            }
        })
    }
}

