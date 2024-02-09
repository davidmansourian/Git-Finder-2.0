//
//  ResultItemView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-09.
//

import SwiftUI

struct ResultItemView: View {
    let user: User
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.avatarUrl)) { image in
                image
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
            }
            
            Text(user.username)
                .fontWeight(.semibold)
        }
        .font(.footnote)
    }
}

#Preview {
    let fakeUser = User(id: 1, username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", reposUrl: "")
    return ResultItemView(user: fakeUser)
}
