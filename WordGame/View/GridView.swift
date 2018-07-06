//
//  UIView.swift
//  WordGame
//
//  Created by William Hu on 7/6/18.
//  Copyright © 2018 William Hu. All rights reserved.
//

import UIKit

final class GridView: UIView {
    private var charaterNodes = [[UILabel]]()
    private var selectedCharacterNodes = [UILabel]()
    
    var viewModel = GridViewModel()
    var width: CGFloat = 0
    var sourceWord: Word? {
        didSet {
            updateCharacterNodes()
        }
    }
    
    func updateCharacterNodes() {
        guard let sourceWord = sourceWord else {
            return
        }
        charaterNodes.removeAll()
        
        width = UIScreen.main.bounds.width/CGFloat(sourceWord.character_grid.count)
        frame = CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: CGFloat(sourceWord.character_grid.count) * width)
        sourceWord.character_grid.enumerated().forEach { (yOffset, element) in
            var la = [UILabel]()
            element.enumerated().forEach({ (xOffset, element) in
                let b = UILabel(frame: CGRect(x: CGFloat(xOffset) * width, y: CGFloat(yOffset) * width, width: width, height: width))
                b.backgroundColor = UIColor.red
                b.text = element
                la.append(b)
                addSubview(b)
            })
            charaterNodes.append(la)
        }
    }
}

extension GridView {
    
    private func nodeLocation(_ point: CGPoint) -> (Int, Int){
        let x = Int((point.x / width).rounded(.down))
        let y = Int((point.y / width).rounded(.down))
        return (x,y)
    }
    
    private func findCurrentSelectedNode(_ location: (Int, Int)) -> UILabel? {
        guard let firstNode = charaterNodes.first,  location.0 < firstNode.count-1, location.1 < charaterNodes.count-1 else {
            return .none
        }
        return charaterNodes[location.1][location.0]
    }
    
    private func changeNodeStatus(node: UILabel, selected: Bool) {
        node.backgroundColor = selected ? UIColor.blue : UIColor.red
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        let touchlocation = touch.location(in: self)
        let position = nodeLocation(touchlocation)
        guard let node = findCurrentSelectedNode(position) else {
            return
        }
//        print("\(x)--\(y)--\(l.text)")
        changeNodeStatus(node: node, selected: true)
        addSelectedNode(node)
        viewModel.addNodePosition(position)
    }
    
    private func addSelectedNode(_ node: UILabel) {
        if !selectedCharacterNodes.contains(node) {
            selectedCharacterNodes.append(node)
        }
    }
    
    private func generateSelectedValue() -> String? {
        let value = selectedCharacterNodes.compactMap{$0.text}.reduce("", + )
        guard !value.isEmpty else {
            return .none
        }
        return value
    }
    func checkSelectedWordCorrect() -> Bool {
        guard let sourceWord = sourceWord, let selectedWordValue = generateSelectedValue(), let selectedWord = viewModel.generateSelectedWord(by: selectedWordValue), selectedWord == sourceWord.word_locations else {
            return false
        }
        return true
    }
    
    func resetStatus() {
        viewModel.selectedCharacterPoints.removeAll()
        UIView.animate(withDuration: 1.0, delay: 0, options: .allowUserInteraction, animations: {
            self.selectedCharacterNodes.forEach {
                self.changeNodeStatus(node: $0, selected: false)
            }
        }, completion: { finished in
            self.selectedCharacterNodes.removeAll()
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = sourceWord else {
            return
        }
        
        if checkSelectedWordCorrect() {
            //update word
        }
        resetStatus()
    }
}

