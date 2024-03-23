//
//  AvatarLoader.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-23.
//

import Foundation
import UIKit

// Probably no need to implement a protocol for this class since as it is?

@Observable
public final class AvatarLoader {
    private let apiService: ApiServing
    private var currentView: CurrentView = .none
    
    private(set) var images = [String: UIImage]()
    
    
    init(apiService: ApiServing) {
        self.apiService = apiService
    }
    
    public func loadAvatarImages(for objects: [Any]?, requestedHeight: CGFloat) async {
        guard let objects = objects else { return }
        await withTaskGroup(of: (String, Data).self) { [weak self] taskGroup in
            guard let self = self else { return }
            for object in objects {
                if let (avatarUrl, username) = determineGenericObjectType(object: object) {
                    await storeImagesIfNecessary(
                        for: username,
                        with: avatarUrl,
                        currentView: .search,
                        requestedHeight: requestedHeight
                    )
                }
            }
        }
    }
    
    @MainActor
    private func storeImagesIfNecessary(for username: String,
                                           with imageUrl: String,
                                           currentView: CurrentView,
                                           requestedHeight: CGFloat) 
    async {
        resetImageDatasIfNecessary(currentView)
        
        if !self.images.keys.contains(username) {
            do {
                let imageData = try await self.apiService.fetchImageData(for: imageUrl)
                let thumbnail = getThumbnailFrom(imageData: imageData, withHeight: requestedHeight)
                self.images[username] = thumbnail
            } catch {
                print("DEBUG: error when fetching image for \(username)")
                print(error)
            }
        } else {
            // print("imageDatas already contains key-value pair of \(username). Skipping operation.")
        }
    }
    
    private func determineGenericObjectType(object: Any) -> (String, String)? {
        if let user = object as? User {
            return (user.avatarUrl, user.username)
        } else if let repo = object as? Repository {
            return (repo.owner.avatarUrl, repo.owner.username)
        }
        
        return nil
    }
    
    @MainActor
    private func resetImageDatasIfNecessary(_ newCurrentView: CurrentView) {
        if newCurrentView != currentView {
            images = [:]
            self.currentView = newCurrentView
        }
    }
    
    private func getThumbnailFrom(imageData: Data, withHeight height: CGFloat) -> UIImage? {
        let image = UIImage(data: imageData)
        guard let thumbnail = image?.aspectFittedToHeight(height) else { return nil }
        thumbnail.jpegData(compressionQuality: 0.1)
        return thumbnail
    }
}

extension AvatarLoader {
    public enum CurrentView {
        case none, search, profile
    }
}

extension UIImage {
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
