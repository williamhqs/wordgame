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
    var nodeWidth: CGFloat = 0 {
        didSet {
            virtalSpace = nodeWidth / 3
        }
    }
    var virtalSpace: CGFloat = 0
    var gridSpace: CGFloat = 2
    var currentColor = UIColor.darkGray
    var lastActionFinished = true
    
    var sourceWord: Word? {
        didSet {
            layoutSubviews()
            updateCharacterNodes()
        }
    }
    
    // MARK: - Life Cycle
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
        self.backgroundColor = UIColor.brown
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let sw = sourceWord {
            nodeWidth = (self.frame.width - gridSpace * CGFloat(sw.character_grid.count + 1))/CGFloat(sw.character_grid.count)
        }
    }
    
    // MARK: - Private Methods
    private func updateCharacterNodes() {
        guard let sourceWord = sourceWord else {
            return
        }
        let stackView1   = UIStackView()
        stackView1.axis  = UILayoutConstraintAxis.vertical
        stackView1.distribution  = UIStackViewDistribution.fillEqually
        stackView1.alignment = UIStackViewAlignment.fill
        stackView1.spacing   = gridSpace
        sourceWord.character_grid.enumerated().forEach { (yOffset, element) in
            var labels = [UILabel]()
            element.enumerated().forEach({ (xOffset, element) in
                let node = self.setupCharacterNode(frame: .zero)
                node.text = element
                labels.append(node)
//                addSubview(node)
            })
            let stackView   = UIStackView(arrangedSubviews: labels)
            stackView.axis  = UILayoutConstraintAxis.horizontal
            stackView.distribution  = UIStackViewDistribution.fillEqually
            stackView.alignment = UIStackViewAlignment.fill
            stackView.spacing   = gridSpace
            stackView1.addArrangedSubview(stackView)
            charaterNodes.append(labels)
        }
        self.addSubview(stackView1)
        stackView1.translatesAutoresizingMaskIntoConstraints = false
        stackView1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: gridSpace).isActive = true
        stackView1.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -gridSpace).isActive = true
        stackView1.topAnchor.constraint(equalTo: self.topAnchor, constant: gridSpace).isActive = true
        stackView1.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -gridSpace).isActive = true
    }
    
    private func setupCharacterNode(frame: CGRect) -> UILabel {
        let b = UILabel(frame: frame)
        b.layer.backgroundColor = currentColor.cgColor
        b.textColor = UIColor.white
        b.adjustsFontSizeToFitWidth = true
        b.textAlignment = .center
        b.font = UIFont.systemFont(ofSize: 25.0)
        return b
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
    
    private func resetToNextStatus() {
        self.lastActionFinished = false
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
    
    private func resetCharacterNodeColor(_ node: UILabel) {
        node.layer.backgroundColor = currentColor.cgColor
    }
    
    private func resetToInitStatus() {
        self.lastActionFinished = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            self.charaterNodes.flatMap{$0}.forEach {
                self.resetCharacterNodeColor($0)
            }
        }, completion: { finished in
            self.clearSingleSelectedNodes()
        })
    }
    
    private func resetParticalNodesColor() {
        self.lastActionFinished = false
        UIView.animate(withDuration: 1.0, delay: 0, options: .allowUserInteraction, animations: {
            self.selectedCharacterNodes.forEach {
                if !self.viewModel.thisTimeCorrect {
                    self.resetCharacterNodeColor($0)
                } else {
                    self.changeNodeStatus(node: $0, correct: .part)
                }
            }
        }, completion: { finished in
            self.clearSingleSelectedNodes()
        })
        
    }
    
    private func clearAllNodes() {
        clearSingleSelectedNodes()
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
        charaterNodes.removeAll()
    }
    
    private func clearSingleSelectedNodes() {
        selectedCharacterNodes.removeAll()
        viewModel.selectedCharacterPoints.removeAll()
        lastActionFinished = true
    }
    
    
    private func nodeLocation(_ point: CGPoint) -> (Int, Int){
        var x = Int(((point.x - gridSpace) / (nodeWidth + gridSpace)).rounded(.down))
        var y = Int(((point.y - gridSpace) / (nodeWidth + gridSpace)).rounded(.down))
        if x < 0 { x = 0 }
        if y < 0 { y = 0 }
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
            color = viewModel.thisTimeCorrect ? UIColor.green : UIColor.red
        case .all:
            color = UIColor.green
        }
        node.layer.backgroundColor = color.cgColor
    }
}

// MARK: - Touches
extension GridView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //Becase of the animation cost time so if the finger move's very fast should clear the cached color
        selectedCharacterNodes.forEach {
            $0.layer.backgroundColor = currentColor.cgColor
        }
        selectedCharacterNodes.removeAll()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard lastActionFinished, let touch = touches.first else {
            return
        }
        
        let touchlocation = touch.location(in: self)
        let position = nodeLocation(touchlocation)
        
        guard let node = findCurrentSelectedNode(position) else {
            return
        }
        
        let relativeGridFrame = CGRect(x: node.frame.minX, y: node.frame.width * CGFloat(position.1), width: node.frame.width, height: node.frame.height)
        let virtualFrame = UIEdgeInsetsInsetRect(relativeGridFrame, UIEdgeInsetsMake(virtalSpace, virtalSpace, 0, 0))
        guard virtualFrame.contains(touchlocation) else {
            return
        }
        changeNodeStatus(node: node, correct: .not)
        addSelectedNode(node)
        viewModel.addNodePosition(position)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = sourceWord, lastActionFinished, let selectedWordValue = generateSelectedValue() else {
            return
        }
        switch viewModel.checkSelectedWordCorrect(selectedWordValue) {
        case .not:
            resetToInitStatus()
        case .part:
            resetParticalNodesColor()
        case .all:
            resetToNextStatus()
        }
    }
}

