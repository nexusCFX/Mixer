//
//  MusicCoordinatorViewController.swift
//  Mixer
//
//  Created by Brandon Chester on 3/16/18.
//  Copyright © 2018 Brandy. All rights reserved.
//

import UIKit

class MusicCoordinatorViewController: UIViewController, MusicCollectionActionDelegate, PlaybackControlActionDelegate, MusicPlayerActionDelegate {
    
    let musicCollection:MusicCollectionViewController
    let controls:PlaybackControlViewController
    var musicPlayer:MixedMusicPlayer
    var currentSong:MusicData?
    
    let controlsDimension:CGFloat = 64
    var audioLevel:Int {
        if let player = musicPlayer.currentPlayer {
            player.updateMeters()
            var power:Float = 0
            for i in 0..<player.numberOfChannels {
                power += player.averagePower(forChannel: i)
            }
            power = power/Float(player.numberOfChannels)
            return min(max(Int(powf(10, power/20)*175), 20) + 10, 100)
        }
        return 50
    }

    init() {
        let layout = MusicCollectionLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        musicPlayer = MixedMusicPlayer()
        musicCollection = MusicCollectionViewController(layout: layout)
        controls = PlaybackControlViewController()
        controls.dimension = controlsDimension
        super.init(nibName: nil, bundle: nil)
        musicCollection.delegate = self
        controls.delegate = self
        musicPlayer.delegate = self
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        self.addChildViewControllers()
        let width = view.bounds.size.width*0.8
        MusicDataLoader.load(albumArtDimension: width) { data in
            DispatchQueue.main.async {
                self.musicCollection.data = data
                self.musicCollection.collectionView?.performBatchUpdates({
                    self.musicCollection.collectionView?.insertSections(IndexSet(integer: 0))
                }, completion: nil)
                self.currentSong = self.musicCollection.data[0]
                self.musicPlayer.load(with: self.currentSong!.fileURL)
                self.view.backgroundColor = self.currentSong!.accentColor
                self.controls.showButtons(animated: true)
            }
        }
    }
    
    override func loadView() {
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
    }
    
    private func addChildViewControllers() {
        addChildViewController(musicCollection)
        view.addSubview(musicCollection.view)
        musicCollection.view.translatesAutoresizingMaskIntoConstraints = false
        musicCollection.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        musicCollection.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(controlsDimension + 10)).isActive = true
        musicCollection.view.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        musicCollection.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        musicCollection.didMove(toParentViewController: self)
        
        addChildViewController(controls)
        view.addSubview(controls.view)
        controls.view.translatesAutoresizingMaskIntoConstraints = false
        controls.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        controls.view.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        controls.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        controls.view.heightAnchor.constraint(equalToConstant: controlsDimension + 30).isActive = true
        controls.didMove(toParentViewController: self)
        controls.hideButtons(animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func musicCollection(_ musicCollection: MusicCollectionViewController, didScroll scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let width = scrollView.bounds.size.width
        let rawIndex = offset/width
        let bottomIndex = Int(rawIndex)
        let topIndex = bottomIndex + 1
        if topIndex >= musicCollection.data.count || rawIndex < 0 { return }
        let fraction = rawIndex - CGFloat(bottomIndex)
        let startColor = musicCollection.data[bottomIndex].accentColor
        let endColor = musicCollection.data[topIndex].accentColor
        view.backgroundColor = UIColor.mixedColor(from: startColor, to: endColor, fraction: fraction)
    }
    
    func musicCollection(_ musicCollection: MusicCollectionViewController, didChangePage pageIndex: Int) {
        if musicCollection.isPlaying {
            let song = self.musicCollection.data[self.musicCollection.currentPageIndex]
            if song.fileURL != self.currentSong?.fileURL {
                self.currentSong = song
                self.musicPlayer.load(with: song.fileURL)
            }
            self.musicPlayer.play()
        }
    }
    
    func musicPlayerDidEndPlayback(_ player: MixedMusicPlayer) {
        if musicCollection.currentPageIndex == musicCollection.data.count - 1 {
            performShuffle()
        } else {
            musicCollection.moveToNextSong()
        }
    }
    
    func didTapPlayButton(_ button: UIButton, state: PlayButtonState) {
        DispatchQueue.global(qos: .default).async {
            if state == .pause {
                let song = self.musicCollection.data[self.musicCollection.currentPageIndex]
                if song.fileURL != self.currentSong?.fileURL {
                    self.currentSong = song
                    self.musicPlayer.load(with: song.fileURL)
                }
                self.musicPlayer.play()
            } else {
                self.musicPlayer.pause()
            }
            DispatchQueue.main.async {
                self.musicCollection.isPlaying = (state == .play) ? false : true
            }
        }
    }
    
    func didTapShuffleButton(_ button: UIButton) {
        performShuffle()
    }
    
    private func performShuffle() {
        controls.playButtonState = .play
        musicCollection.isPlaying = false
        musicCollection.shuffle {
            UIView.animate(withDuration: 0.1) {
                self.view.backgroundColor = self.musicCollection.data[0].accentColor
            }
            DispatchQueue.global(qos: .default).async {
                let song = self.musicCollection.data[self.musicCollection.currentPageIndex]
                if song.fileURL != self.currentSong?.fileURL {
                    self.currentSong = song
                    self.musicPlayer.load(with: song.fileURL)
                }
                self.musicPlayer.play()
                DispatchQueue.main.async {
                    self.controls.playButtonState = .pause
                    self.musicCollection.isPlaying = true
                }
            }
        }
    }
}
