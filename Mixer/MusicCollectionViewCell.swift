//
//  MusicCollectionViewCell.swift
//  Mixer
//
//  Created by Brandon Chester on 3/16/18.
//  Copyright © 2018 Brandy. All rights reserved.
//

import UIKit

class MusicCollectionViewCell: UICollectionViewCell {
    
    var visualizer:MusicVisualizer?
    var albumImage:UIImageView
    var shadowView:UIView
    var container:UIView
    var accentColor:UIColor!
    
    var title:UILabel!
    var artist:UILabel!
    
    private var textStack:UIStackView
    
    override init(frame: CGRect) {
        container = UIView()
        shadowView = ShadowContainer(child: container, opacity: 0.2, radius: 5)
        albumImage = UIImageView()
        title = UILabel()
        artist = UILabel()
        textStack = UIStackView(arrangedSubviews: [title, artist])
        super.init(frame: frame)
        addSubview(shadowView)
        addSubview(textStack)
        addSubview(albumImage)
        
        container.backgroundColor = UIColor.white
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 20
        container.layer.rasterizationScale = UIScreen.main.scale
        container.layer.shouldRasterize = true
        
        albumImage.contentMode = .scaleAspectFit
        albumImage.layer.shadowOffset = CGSize(width: 0, height: 3)
        albumImage.layer.shadowRadius = 10
        albumImage.layer.shadowOpacity = 0.3
        
        title.backgroundColor = UIColor.white
        title.font = UIFont.systemFont(ofSize: 24, weight: .black)
        title.numberOfLines = 0
        title.textAlignment = .center
        
        artist.backgroundColor = UIColor.white
        artist.font = UIFont.systemFont(ofSize: 24, weight: .black)
        artist.numberOfLines = 0
        artist.textAlignment = .center
        
        textStack.spacing = 10
        textStack.alignment = .center
        textStack.axis = .vertical
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textStack.widthAnchor.constraint(equalTo: albumImage.widthAnchor).isActive = true
        textStack.topAnchor.constraint(equalTo: albumImage.bottomAnchor, constant: 15).isActive = true
    }
    
    // Pure auto layout solution seemed too slow
    override func layoutSubviews() {
        shadowView.frame = CGRect(
            x: 20,
            y: 15,
            width: frame.width - 40,
            height: frame.height - 40
        )
        albumImage.frame = CGRect(
            x: shadowView.frame.origin.x + shadowView.frame.width*0.1,
            y: shadowView.frame.origin.y + shadowView.frame.width*0.1,
            width: shadowView.frame.width*0.8,
            height: shadowView.frame.width*0.8
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        visualizer?.removeFromSuperview()
        visualizer = nil
    }
    
    func populate(with data: MusicData) {
        self.title.text = data.trackName
        self.title.textColor = data.accentColor
        self.artist.text = data.artist
        self.artist.textColor = data.accentColor
        albumImage.image = data.image
        self.accentColor = data.accentColor
    }
    
    func addVisualizer() {
        guard visualizer == nil else { return }
        visualizer = MusicVisualizer(frame: CGRect(x: shadowView.frame.minX + container.layer.cornerRadius,
                                                   y: textStack.frame.maxY,
                                                   width: shadowView.frame.width - container.layer.cornerRadius*2,
                                                   height: shadowView.frame.maxY - textStack.frame.maxY - 4).integral, accentColor: accentColor)
        addSubview(visualizer!)
    }
    
    func removeVisualizer() {
        visualizer?.removeFromSuperview()
        visualizer = nil
    }
}
