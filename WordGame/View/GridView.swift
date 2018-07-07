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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initSetup()
    }
    
    private func initSetup() {
        viewModel.newSourceWord = { [unowned self] word in
            self.sourceWord = word
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - t
    func updateCharacterNodes() {
        guard let sourceWord = sourceWord else {
            return
        }
        self.clearAllNodes()
        width = UIScreen.main.bounds.width/CGFloat(sourceWord.character_grid.count)
        frame = CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: CGFloat(sourceWord.character_grid.count) * width)
        sourceWord.character_grid.enumerated().forEach { (yOffset, element) in
            var la = [UILabel]()
            element.enumerated().forEach({ (xOffset, element) in
                let b = UILabel(frame: CGRect(x: CGFloat(xOffset) * width, y: CGFloat(yOffset) * width, width: width, height: width))
                b.layer.backgroundColor = UIColor.gray.cgColor
                b.textColor = UIColor.white
                b.textAlignment = .center
                b.font = UIFont.systemFont(ofSize: 25.0)
                b.text = element
                la.append(b)
                addSubview(b)
            })
            charaterNodes.append(la)
        }
    }
}

// MARK: - Touches
extension GridView {
    
    private func nodeLocation(_ point: CGPoint) -> (Int, Int){
        let x = Int((point.x / width).rounded(.down))
        let y = Int((point.y / width).rounded(.down))
        return (x,y)
    }
    
    private func findCurrentSelectedNode(_ location: (Int, Int)) -> UILabel? {
        guard let firstNode = charaterNodes.first,  location.0 < firstNode.count, location.1 < charaterNodes.count else {
            return .none
        }
        return charaterNodes[location.1][location.0]
    }
    
    private func changeNodeStatus(node: UILabel, correct: WordCorrect) {
        var color: UIColor
        switch correct {
        case .not:
            color = UIColor.red
        case .part:
            if viewModel.thisTimeCorrect {
                color = UIColor.green
            } else {
                color = UIColor.red
            }
        case .all:
            color = UIColor.green
        }
        node.layer.backgroundColor = color.cgColor
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
        changeNodeStatus(node: node, correct: .not)
        
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
    
    func resetStatusCorrect() {
        UIView.animate(withDuration: 1.0, delay: 0, options: .allowUserInteraction, animations: {
            self.selectedCharacterNodes.forEach {
                self.changeNodeStatus(node: $0, correct: .all)
            }
        }, completion: { finished in
            self.clearAllNodes()
            self.viewModel.next()
            self.viewModel.showCorrectTargetWord()
        })
    }
    
    func resetCharacterNodeColor(_ node: UILabel) {
        node.layer.backgroundColor = UIColor.gray.cgColor
    }
    
    func resetStatus() {
        UIView.animate(withDuration: 1.0, delay: 0, options: .allowUserInteraction, animations: {
            self.selectedCharacterNodes.forEach {
                self.resetCharacterNodeColor($0)
            }
        }, completion: { finished in
            self.clearAllNodes()
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = sourceWord, let selectedWordValue = generateSelectedValue() else {
            return
        }
        
        switch viewModel.checkSelectedWordCorrect(selectedWordValue) {
        case .not:
            resetStatus()
        case .part:
            setParticalNodesColor()
            break
        case .all:
            resetStatusCorrect()
        }
    }
    
    func setParticalNodesColor() {
        let thisCorrect = viewModel.thisTimeCorrect ? WordCorrect.part : .not
        UIView.animate(withDuration: 1.0, delay: 0, options: .allowUserInteraction, animations: {
            self.selectedCharacterNodes.forEach {
                self.changeNodeStatus(node: $0, correct: thisCorrect)
            }
        }, completion: { finished in
            self.clearAllNodes()
        })
        
    }
    
    private func clearAllNodes() {
        selectedCharacterNodes.removeAll()
        viewModel.selectedCharacterPoints.removeAll()
    }
}

