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
            if let image = UIImage(data: user.avatarImageData) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            }
            
            Text(user.username)
                .fontWeight(.semibold)
        }
        .font(.footnote)
    }
}

extension ProfileResultItemView {
    private var avatarImage: some View {
        AsyncImage(url: URL(string: user.avatarUrl)) { image in
            image
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
        } placeholder: {
            ProgressView()
                .frame(width: 32, height: 32)
        }
    }
}

#Preview {
    let fakeUser = User(username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", reposUrl: "", avatarImageData: Data())
    return ProfileResultItemView(user: fakeUser)
}
