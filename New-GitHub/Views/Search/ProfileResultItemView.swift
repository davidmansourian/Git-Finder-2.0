//
//  ResultItemView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import SwiftUI

struct ProfileResultItemView: View {
    let username: String
    let userType: String
    let image: UIImage?
    
    var body: some View {
        HStack {
            avatarImage
            
            Text(username)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text(userType)
                .fontWeight(.ultraLight)
        }
        .font(.footnote)
    }
}

extension ProfileResultItemView {
    var avatarImage: some View {
        if let avatarUiImage = image {
            let image = Image(uiImage: avatarUiImage)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 32, height: 32)
            return AnyView(image)
        } else {
            let placeHolder = Image(systemName: "person.crop.circle.badge.questionmark.fill")
                .foregroundStyle(.gray)
                .font(.system(size: 24))
            return AnyView(placeHolder)
        }
    }
}

#Preview {
    let testAvatar = UIImage(named: "testAvatar")
    let fakeUser = User(id: 1, username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", url: "https://api.github.com/users/davidmansourian", reposUrl: "", type: "User")
    return ProfileResultItemView(username: fakeUser.username, userType: fakeUser.type, image: testAvatar)
}
