//
//  MusicCollectionViewController.swift
//  Mixer
//
//  Created by Brandon Chester on 3/16/18.
//  Copyright © 2018 Brandy. All rights reserved.
//

import UIKit

class MusicCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var currentPageIndex = 0
    var data:[MusicData]!
    var isPlaying = false {
        didSet {
            if isPlaying {
                link.isPaused = false
            } else {
                link.isPaused = true
                stopVisualizer(instantly: false)
            }
        }
    }
    
    var link:CADisplayLink!
    weak var delegate:MusicCollectionActionDelegate?

    init(layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(MusicCollectionViewCell.self, forCellWithReuseIdentifier: "musicCell")
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        link = UIScreen.main.displayLink(withTarget: self, selector: #selector(MusicCollectionViewController.runVisualizer))
        link.add(to: RunLoop.current, forMode: .commonModes)
        link.isPaused = true
        link.preferredFramesPerSecond = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        (collectionViewLayout as! MusicCollectionLayout).itemSize = CGSize(width: view.bounds.width, height: view.bounds.height)
    }
    
    deinit {
        link.remove(from: RunLoop.current, forMode: .commonModes)
    }
    
    @objc func runVisualizer() {
        if let cell = self.collectionView?.cellForItem(at: IndexPath(row: self.currentPageIndex, section: 0)) as? MusicCollectionViewCell {
            if let visualizer = cell.visualizer {
                visualizer.animate(delegate?.audioLevel ?? 50)
            } else {
                cell.addVisualizer()
            }
        }
    }
    
    func stopVisualizer(instantly: Bool) {
        if let cell = self.collectionView?.cellForItem(at: IndexPath(row: self.currentPageIndex, section: 0)) as? MusicCollectionViewCell {
            if let visualizer = cell.visualizer {
                visualizer.stopAnimating(instantly: instantly)
            }
        }
    }

    func shuffle(completion: @escaping () -> Void) {
        data.shuffle(blocking: currentPageIndex)
        let shuffled = data
        data = nil
        collectionView?.delegate = nil
        collectionView?.performBatchUpdates({
            self.collectionView?.deleteSections(IndexSet(integer: 0))
        }, completion: { (finished) in
            self.collectionView?.performBatchUpdates({
                self.data = shuffled
                self.collectionView?.insertSections(IndexSet(integer: 0))
            }, completion: { (finished) in
                self.currentPageIndex = 0
                self.collectionView?.delegate = self
               // self.runVisualizer()
                completion()
            })
        })
    }
    
    func moveToNextSong() {
        currentPageIndex += 1
        collectionView?.scrollToItem(at: IndexPath(item: currentPageIndex, section: 0), at: .centeredHorizontally, animated: true)
        delegate?.musicCollection(self, didChangePage: currentPageIndex)
        if let cell = self.collectionView?.cellForItem(at: IndexPath(row: currentPageIndex, section: 0)) as? MusicCollectionViewCell {
            cell.addVisualizer()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data == nil ? 0 : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let width = scrollView.bounds.size.width
        let index = Int(offset/width)
        // Add the visualizer to the new centered page
        if let cell = collectionView?.cellForItem(at: IndexPath(row: index, section: 0)) as? MusicCollectionViewCell {
            cell.addVisualizer()
        }
        if index != currentPageIndex {
            currentPageIndex = index
            delegate?.musicCollection(self, didChangePage: index)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.musicCollection(self, didScroll: scrollView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? MusicCollectionViewCell {
            cell.removeVisualizer()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "musicCell", for: indexPath) as! MusicCollectionViewCell
        cell.populate(with: data[indexPath.item])
        return cell
    }
    
 /*   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height
        )
    }*/
}

protocol MusicCollectionActionDelegate: AnyObject {
    func musicCollection(_ musicCollection:MusicCollectionViewController, didScroll scrollView: UIScrollView)
    func musicCollection(_ musicCollection:MusicCollectionViewController, didChangePage pageIndex:Int)
    var audioLevel:Int { get }
}
