//
//  MusicData.swift
//  Mixer
//
//  Created by Brandon Chester on 3/17/18.
//  Copyright © 2018 Brandy. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

// For large data sets it'd probably be best to load all this on demand
// or in chunks. Probably prefetch api + async loading.
class MusicDataLoader {
    
    static func load(albumArtDimension: CGFloat, completion: @escaping ([MusicData]) -> Void) {
        DispatchQueue.global().async {
            var data = [MusicData]()
            let paths = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil) + Bundle.main.paths(forResourcesOfType: "m4a", inDirectory: nil)
            
            for path in paths {
                let fileURL = URL(fileURLWithPath: path)
                let asset = AVURLAsset(url: fileURL)
                
                var title:String!
                var artist:String!
                var album:String!
                var image:UIImage!
                
                for metadata in asset.commonMetadata {
                    if metadata.commonKey == AVMetadataKey.commonKeyTitle {
                        title = metadata.stringValue!
                    }
                    if metadata.commonKey == AVMetadataKey.commonKeyArtist {
                        artist = metadata.stringValue!
                    }
                    if metadata.commonKey == AVMetadataKey.commonKeyAlbumName {
                        album = metadata.stringValue!
                    }
                    if metadata.commonKey == AVMetadataKey.commonKeyArtwork {
                        image = UIImage.roundedImage(imageData: metadata.dataValue!, cornerRadius: 20, dimension: albumArtDimension)
                    }
                }
                data.append(MusicData(fileURL: fileURL, trackName: title, artist: artist, album: album, image: image))
            }
            data.shuffle()
            data.insert(data.remove(at: data.index { $0.artist == "Trigger" }!), at: 0)
            completion(data)
        }
    }
}

struct MusicData {
    let fileURL:URL
    let trackName:String
    let artist:String
    let album:String
    let image:UIImage
    let accentColor:UIColor
    
    init(fileURL: URL, trackName: String, artist: String, album: String, image: UIImage) {
        self.fileURL = fileURL
        self.trackName = trackName
        self.album = album
        self.artist = artist
        self.image = image
        self.accentColor = image.computeAverageColor()
    }
}
