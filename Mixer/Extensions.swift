//
//  Extensions.swift
//  Mixer
//
//  Created by Brandon Chester on 3/16/18.
//  Copyright © 2018 Brandy. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    // Slow, but okay for this purpose.
    mutating func shuffle() {
        for _ in indices {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
    
    // It's boring when your shuffle puts the current song in front
    mutating func shuffle(blocking index: Int) {
        if index >= count { return }
        let element = remove(at: index)
        shuffle()
        let middleIndex = count/2
        insert(element, at: middleIndex)
    }
}

extension UIView {
    func embedInsideAndFill(superView: UIView) {
        superView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([leftAnchor.constraint(equalTo: superView.leftAnchor),
                                     rightAnchor.constraint(equalTo: superView.rightAnchor),
                                     topAnchor.constraint(equalTo: superView.topAnchor),
                                     bottomAnchor.constraint(equalTo: superView.bottomAnchor)])
    }
}

extension UIColor {
    static func colorMaxingMaxComponent(_ color: UIColor) -> UIColor {
        let components = color.cgColor.components!
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = components[3]
        if (r >= g && r >= b) {
            return UIColor(red: 1, green: g, blue: b, alpha: a)
        } else if (g >= r && g >= b) {
            return UIColor(red: r, green: 1, blue: b, alpha: a)
        } else {
            return UIColor(red: r, green: g, blue: 1, alpha: a)
        }
    }
    
    static func mixedColor(from start: UIColor, to end: UIColor, fraction: CGFloat) -> UIColor {
        let s = start.cgColor.components!
        let e = end.cgColor.components!
        let r = s[0] + (e[0] - s[0])*fraction
        let g = s[1] + (e[1] - s[1])*fraction
        let b = s[2] + (e[2] - s[2])*fraction
        let a = s[3] + (e[3] - s[3])*fraction
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension UIImage {
    
    static func roundedImage(imageData:Data, cornerRadius: CGFloat, dimension: CGFloat) -> UIImage {
        let image = UIImage(data: imageData)!
        let aspectRatio = image.size.height / image.size.width
        var size:CGSize!
        if aspectRatio >= 1 {
            size = CGSize(width: dimension/aspectRatio, height: dimension)
        } else {
            size = CGSize(width: dimension, height: dimension*aspectRatio)
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 2)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        image.draw(in: rect)
        let roundImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return roundImage
    }

    static func image(from layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // This doesn't work as nicely as I'd like. I really need something like the most prominent color
    // Note: If you go to WWWDC, ask to talk to Core Image and iTunes engineers about their album art
    // color matching
    func computeAverageColor() -> UIColor {
        let context = CIContext() // I think this is slow to create but it's ok for this playground.
        var bmp = [UInt8](repeating: 0, count: 4)
        let inputImage = self.ciImage ?? CIImage(image: self)!
        let extent = inputImage.extent
        
        let vibeFilter = CIFilter(name: "CIVibrance", withInputParameters: [kCIInputImageKey: inputImage, "inputAmount": NSNumber(value: 0.8)])!
        let vibeImage = vibeFilter.outputImage!
        
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: 20, w: extent.size.height)
        let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: vibeImage, kCIInputExtentKey: inputExtent])!
        let outputImage = filter.outputImage!
        context.render(outputImage,
                       toBitmap: &bmp,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: kCIFormatRGBA8,
                       colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
        return UIColor(red: CGFloat(bmp[0])/255.0,
                       green: CGFloat(bmp[1])/255.0,
                       blue: CGFloat(bmp[2])/255.0,
                       alpha: CGFloat(bmp[3])/255.0)
    }
}
