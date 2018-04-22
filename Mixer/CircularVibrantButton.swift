//
//  CircularVibrantButton.swift
//  Mixer
//
//  Created by Brandon Chester on 3/17/18.
//  Copyright © 2018 Brandy. All rights reserved.
//

import UIKit

class CircularVibrantButton: UIView {
    
    let button:UIButton
    
    init(image: UIImage, dimension: CGFloat) {
        button = UIButton()
        super.init(frame: CGRect.zero)
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        
        blurredEffectView.layer.masksToBounds = true
        blurredEffectView.layer.cornerRadius = dimension/2
        
        button.embedInsideAndFill(superView: vibrancyView.contentView)
        vibrancyView.embedInsideAndFill(superView: blurredEffectView.contentView)
        blurredEffectView.embedInsideAndFill(superView: self)
        
        layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: dimension, height: dimension), cornerRadius: dimension/2).cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
