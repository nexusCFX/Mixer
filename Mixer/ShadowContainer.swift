//
//  ShadowContainer.swift
//  Mixer
//
//  Created by Brandon Chester on 3/20/18.
//  Copyright © 2018 Brandy. All rights reserved.
//

import UIKit

class ShadowContainer: UIView {
    
    private let child:UIView
    
    init(child: UIView, opacity: Float, radius: CGFloat) {
        self.child = child
        super.init(frame: CGRect.zero)
        addSubview(child)
        backgroundColor = UIColor.clear
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        child.frame = bounds
    }
}
