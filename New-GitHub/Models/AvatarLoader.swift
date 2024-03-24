//
//  AvatarLoader.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-23.
//

import Foundation
import SwiftUI

// Probably no need to implement a protocol for this class since it is testable as it is?

struct AvatarLoader {
    private let apiService: ApiServing
    
    init(apiService: ApiServing) {
        self.apiService = apiService
    }
    
    public func loadAvatarImages(
        for objects: [Any]?,
        requestedHeight: CGFloat,
        currentAvatars: [String:UIImage]? = nil
    ) async throws -> [String: UIImage]  {
        guard let objects = objects else { throw LoadingError.invalidObjects }
        
        var avatarImages: [String:UIImage] = currentAvatars ?? [String:UIImage]()
        
        await withTaskGroup(of: (String, Data).self) { taskGroup in
            
            for object in objects {
                
                if let (avatarUrl, username) = determineGenericObjectType(object: object),
                   !avatarImages.keys.contains(username) {
                    
                    let avatarThumbnail = try? await thumbnail(
                        for: username,
                        with: avatarUrl,
                        requestedHeight: requestedHeight
                    )
                    
                    avatarImages[username] = avatarThumbnail
                }
            }
        }
        
        return avatarImages
    }
    
    private func thumbnail(for username: String,
                           with imageUrl: String,
                           requestedHeight: CGFloat)
    async throws -> UIImage {
        do {
            let imageData = try await self.apiService.fetchImageData(for: imageUrl)
            
            guard let thumbnail = getThumbnailFrom(
                imageData: imageData,
                withHeight: requestedHeight
            ) else {
                throw LoadingError.thumbnailError(
                    "Error creating thumbnail"
                )
            }
            
            return thumbnail
        } catch {
            throw LoadingError.thumbnailError(error.localizedDescription)
        }
    }
    
    private func determineGenericObjectType(object: Any) -> (String, String)? {
        if let user = object as? User {
            return (user.avatarUrl, user.username)
        } else if let repo = object as? Repository {
            return (repo.owner.avatarUrl, repo.owner.username)
        } else if let contributor = object as? Contributor {
            return (contributor.avatarUrl, contributor.username)
        }
        
        return nil
    }
        
    private func getThumbnailFrom(imageData: Data, withHeight height: CGFloat) -> UIImage? {
        let image = UIImage(data: imageData)
        guard let thumbnail = image?.aspectFittedToHeight(height) else { return nil }
        thumbnail.jpegData(compressionQuality: 0.1)
        return thumbnail
    }
}

extension AvatarLoader {
    public enum LoadingError: LocalizedError {
        case invalidObjects, thumbnailError(String)
        
        public var errorDescription: String? {
            switch self {
            case .invalidObjects:
                return "Invalid objects, couldn't continue"
            case .thumbnailError(let error):
                return "Couldn't get thumbnail: \(error)"
            }
        }
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
