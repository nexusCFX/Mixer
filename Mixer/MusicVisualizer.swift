//
//  MusicVisualizer.swift
//  Mixer
//
//  Created by Brandon Chester on 3/16/18.
//  Copyright © 2018 Brandy. All rights reserved.
//

import UIKit

// In a perfect world this would have a View Controller but it's going inside UICollectioViewCells
// and this is a Swift Playground
class MusicVisualizer: UIView {
    private let stack:UIStackView
    private let accent:UIColor
    private let numBars:Int
    private let barSpacing:CGFloat
    private let barHeightConstraints:[NSLayoutConstraint]
    
    init(frame: CGRect, barCount: Int = 8, spacing: CGFloat = 6, accentColor: UIColor) {
        accent = accentColor
        numBars = barCount
        barSpacing = spacing
        
        let gradient = CAGradientLayer()
        gradient.colors = [accentColor.cgColor, UIColor.colorMaxingMaxComponent(accentColor).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let gradientImage = UIImage.image(from: gradient)
        let barWidth = (frame.width - CGFloat(numBars - 1)*barSpacing)/CGFloat(numBars)
        
        var bars = [UIView]()
        var barConstraints = [NSLayoutConstraint]()
        for i in 0..<numBars {
            let bar = UIView()
            bar.backgroundColor = UIColor.cyan
            let offset = CGFloat(i)*(barWidth + barSpacing)
            let maxBarFrame = CGRect(x: offset, y: 0, width: barWidth, height: frame.height)
            let barImage = gradientImage.cgImage?.cropping(to: maxBarFrame)
            let barImageView = UIImageView(image: UIImage(cgImage: barImage!))
            barImageView.layer.cornerRadius = 6
            barImageView.layer.masksToBounds = true
            let heightConstraint = barImageView.heightAnchor.constraint(equalToConstant: 0)
            barConstraints.append(heightConstraint)
            bars.append(barImageView)
        }
        
        stack = UIStackView(arrangedSubviews: bars)
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.distribution = .fillEqually
        stack.spacing = barSpacing
        barHeightConstraints = barConstraints
        super.init(frame: frame)
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        NSLayoutConstraint.activate(barHeightConstraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate(_ peak:Int) {
        layoutIfNeeded()
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
            for c in self.barHeightConstraints {
                let random = arc4random_uniform(UInt32(peak))
                c.constant = (CGFloat(random)/100)*self.stack.frame.height
            }
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func stopAnimating(instantly: Bool) {
        let duration = instantly ? 0 : 0.2
        layoutIfNeeded()
        UIView.animate(withDuration: duration) {
            for c in self.barHeightConstraints {
                c.constant = 0
            }
            self.layoutIfNeeded()
        }
    }
}
