//
//  ProfileCardView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-17.
//

import SwiftUI

struct RepositoryCardView: View {
    let image: UIImage?
    let mainProfileUsername: String
    let repository: Repository
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(repository.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("View repository")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            if let description = repository.description {
                Text(description)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .padding(.vertical, 5)
            }
            
            HStack {
                avatarImage
                
                Text("owned by \(owner)")
                
                Spacer()
                
                Image(systemName: "eye")
                    .foregroundStyle(.gray)
                    .opacity(0.2)
                Text("\(watchers) watchers")
            }
            .font(.caption)
            .fontWeight(.ultraLight)
            .padding(.top, 10)
            
            if repository.owner.username != mainProfileUsername {
                Text("\(mainProfileUsername) is a contributor")
                    .foregroundColor(.blue)
                    .font(.caption2)
                    .fontWeight(.light)
                    .padding(.top, 5)
            }
            
        }
    }
}

private extension RepositoryCardView {
    var owner: String {
        repository.owner.username
    }
    
    var watchers: String {
        String(repository.watchersCount)
    }
    
    var avatarImage: some View {
        if let avatarUiImage = image {
            let image = Image(uiImage: avatarUiImage)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 18, height: 18)
            return AnyView(image)
        } else {
            let placeHolder = Image(systemName: "person.crop.circle.badge.questionmark.fill")
                .foregroundStyle(.gray)
            return AnyView(placeHolder)
        }
    }
}

#Preview {
    let mockImage = UIImage(named: "testAvatar")
    let fakeRepoOwner = Repository.Owner(username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4")
    let fakeRepository = Repository(name: "Pelle's Project", owner: fakeRepoOwner, description: "I am Pelle. This is my project, and I am very proud of it.", starGazersCount: 12, watchersCount: 33, forksCount: 25, lastUpdated: "2023-09-05T22:41:23Z", defaultBranch: "main")
    return RepositoryCardView(image: mockImage, mainProfileUsername: "Palle", repository: fakeRepository)
}
