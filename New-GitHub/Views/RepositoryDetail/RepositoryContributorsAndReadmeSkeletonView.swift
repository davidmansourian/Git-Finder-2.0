//
//  RepositoryContributorsAndReadmeSkeletonView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import SwiftUI

struct RepositoryContributorsAndReadmeSkeletonView: View {
    @State var avatars: [IndexedAvatar] = []
    
    init() {
        if let avatar = UIImage(named: "testAvatar") {
            
            let indexedAvatar1 = IndexedAvatar(id: 0, avatar: avatar)
            let indexedAvatar2 = IndexedAvatar(id: 1, avatar: avatar)
            let indexedAvatar3 = IndexedAvatar(id: 2, avatar: avatar)
            
            avatars.append(indexedAvatar1)
            avatars.append(indexedAvatar2)
            avatars.append(indexedAvatar3)
        }
    }
    var body: some View {
        HStack(spacing: 100) {
                VStack {
                    ZStack {
                        ForEach(0...2, id: \.self) { index in
                            if let avatar = UIImage(named: "testAvatar") {
                                avatarImage(width: 40, height: 40, avatarImage: avatar)
                                    .offset(x: CGFloat(index*10))
                            }
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        Text("Contributors")
                    }
                }
            
            VStack(spacing: 4) {
                Image(systemName: "doc")
                    .font(.system(size: 40))
                
                Button {
                    
                } label: {
                    Text("Read me")
                }
            }
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

extension RepositoryContributorsAndReadmeSkeletonView {
    func avatarImage(width: CGFloat, height: CGFloat, avatarImage: UIImage?) -> some View {
        if let avatarUiImage = avatarImage {
            let image = Image(uiImage: avatarUiImage)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: width, height: height)
            return AnyView(image)
        } else {
            let placeHolder = Image(systemName: "person.crop.circle.badge.questionmark.fill")
                .foregroundStyle(.gray)
            return AnyView(placeHolder)
        }
    }
}

#Preview {
    RepositoryContributorsAndReadmeSkeletonView()
}
