//
//  ProfileCardView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-17.
//

import SwiftUI

struct RepositoryCardView: View {
    let repository: Repository
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(repository.name)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("View repository")
                    .foregroundStyle(.blue)
            }
            
            if let description = repository.description {
                Text(description)
                    .font(.callout)
                    .padding(.vertical, 5)
            }
            
            HStack {
                avatarImage
                
                Text("owned by \(owner)")
                
                Spacer()
                
                Image(systemName: "eye")
                    .foregroundStyle(.gray)
                Text("\(watchers) watchers")
            }
            .font(.footnote)
            .fontWeight(.ultraLight)
            .padding(.top, 10)
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
        if let avatarData = repository.owner.avatarData,
           let avatar = UIImage(data: avatarData) {
            let image = Image(uiImage: avatar)
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
    let avatar = UIImage(named: "testAvatar")
    let avatarData = avatar?.jpegData(compressionQuality: 0.9)
    let fakeRepoOwner = RepositoryOwner(username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", avatarData: avatarData)
    let fakeRepository = Repository(name: "Pelle's Project", owner: fakeRepoOwner, description: "I am Pelle. This is my project, and I am very proud of it.", starGazersCount: 12, watchersCount: 33, forksCount: 25)
    return RepositoryCardView(repository: fakeRepository)
}
