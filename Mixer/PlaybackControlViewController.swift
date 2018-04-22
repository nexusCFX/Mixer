//
//  PlaybackControlViewController.swift
//  Mixer
//
//  Created by Brandon Chester on 3/16/18.
//  Copyright © 2018 Brandy. All rights reserved.
//

import UIKit

class PlaybackControlViewController: UIViewController {

    var playButtonState:PlayButtonState = .play {
        didSet {
            if playButtonState == .play {
                playButton.button.setImage(UIImage(named: "play")?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                playButton.button.setImage(UIImage(named: "pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
    }
    var playButton:CircularVibrantButton!
    var shuffleButton:CircularVibrantButton!

    weak var delegate:PlaybackControlActionDelegate?
    var dimension:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        playButton = CircularVibrantButton(image: UIImage(named: "play")!, dimension: dimension)
        shuffleButton = CircularVibrantButton(image: UIImage(named: "shuffle")!, dimension: dimension)
        
        view.addSubview(playButton)
        view.addSubview(shuffleButton)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.widthAnchor.constraint(equalToConstant: dimension).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: dimension).isActive = true
        playButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: view.frame.width/4).isActive = true
        playButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        shuffleButton.translatesAutoresizingMaskIntoConstraints = false
        shuffleButton.widthAnchor.constraint(equalToConstant: dimension).isActive = true
        shuffleButton.heightAnchor.constraint(equalToConstant: dimension).isActive = true
        shuffleButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -view.frame.width/4).isActive = true
        shuffleButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        playButton.button.addTarget(self, action: #selector(PlaybackControlViewController.tapInsidePlay), for: .touchDown)
        playButton.button.addTarget(self, action: #selector(PlaybackControlViewController.didTapPlay), for: .touchUpInside)
        playButton.button.addTarget(self, action: #selector(PlaybackControlViewController.tapOutsidePlay), for: .touchUpOutside)
        
        shuffleButton.button.addTarget(self, action: #selector(PlaybackControlViewController.tapInsideShuffle), for: .touchDown)
        shuffleButton.button.addTarget(self, action: #selector(PlaybackControlViewController.didTapShuffle), for: .touchUpInside)
        shuffleButton.button.addTarget(self, action: #selector(PlaybackControlViewController.tapOutsideShuffle), for: .touchUpOutside)
        
    }
    
    func showButtons(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                self.showButtons()
            }, completion: nil)
        } else {
            showButtons()
        }
    }
    
    private func showButtons() {
        shuffleButton.transform = CGAffineTransform.identity
        playButton.transform = CGAffineTransform.identity
    }
    
    func hideButtons(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.hideButtons()
            }
        } else {
            hideButtons()
        }
    }
    
    private func hideButtons() {
        shuffleButton.transform = shuffleButton.transform.translatedBy(x: -view.frame.width, y: 0)
        playButton.transform = playButton.transform.translatedBy(x: view.frame.width, y: 0)
    }
    
    @objc func tapInsideShuffle() {
        UIView.animate(withDuration: 0.1) {
            self.shuffleButton.transform = self.shuffleButton.transform.scaledBy(x: 0.9, y: 0.9)
        }
    }
    
    @objc func tapInsidePlay() {
        UIView.animate(withDuration: 0.1) {
            self.playButton.transform = self.playButton.transform.scaledBy(x: 0.9, y: 0.9)
        }
    }
    
    @objc func tapOutsideShuffle() {
        UIView.animate(withDuration: 0.1) {
            self.shuffleButton.transform = CGAffineTransform.identity
        }
    }
    
    @objc func tapOutsidePlay() {
        UIView.animate(withDuration: 0.1) {
            self.playButton.transform = CGAffineTransform.identity
        }
    }
    
    @objc func didTapPlay() {
        UIView.animate(withDuration: 0.1) {
            self.playButton.transform = CGAffineTransform.identity
        }
        playButtonState = (playButtonState == .play) ? .pause : .play
        delegate?.didTapPlayButton(playButton.button, state: playButtonState)
    }
    
    @objc func didTapShuffle() {
        UIView.animate(withDuration: 0.1) {
            self.shuffleButton.transform = CGAffineTransform.identity
        }
        delegate?.didTapShuffleButton(shuffleButton.button)
    }
}

protocol PlaybackControlActionDelegate: AnyObject {
    func didTapPlayButton(_ button: UIButton, state:PlayButtonState)
    func didTapShuffleButton(_ button: UIButton)
}

enum PlayButtonState {
    case play, pause
}
