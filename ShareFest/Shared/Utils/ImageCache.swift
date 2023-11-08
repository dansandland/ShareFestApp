//
//  ImageCache.swift
//  ShareFest
//
//  Created by Daniel Sandland on 11/7/23.
//

import UIKit

final class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func getImage(for url: URL) -> UIImage? {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            return cachedImage
        }
        return nil
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url.absoluteString as NSString)
    }
    
    func loadImage(from url: URL) async throws -> UIImage? {
        // Check if in cache
        if let cached = getImage(for: url) {
            return cached
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        if let image = UIImage(data: data) {
            // Cache image
            ImageCache.shared.setImage(image, for: url)
            return image
        }
        
        return nil
    }
}
