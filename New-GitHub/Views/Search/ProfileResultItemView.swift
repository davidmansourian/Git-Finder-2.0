//
//  ResultItemView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import SwiftUI

struct ProfileResultItemView: View {
    let user: User
    var body: some View {
        HStack {
            if let imageData = user.avatarImageData,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            }
            
            Text(user.username)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text(user.type)
                .fontWeight(.ultraLight)
        }
        .font(.footnote)
    }
}

#Preview {
    let testAvatar = UIImage(named: "testAvatar")
    let avatarData = testAvatar?.pngData()
    let fakeUser = User(id: 1, username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", url: "https://api.github.com/users/davidmansourian", reposUrl: "", type: "User", avatarImageData: avatarData)
    return ProfileResultItemView(user: fakeUser)
}
