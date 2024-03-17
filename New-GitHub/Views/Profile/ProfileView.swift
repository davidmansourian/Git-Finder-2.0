//
//  ProfileView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-17.
//

import SwiftUI

struct ProfileView: View {
    private let apiService: ApiServing
    private let user: User
    
    @State private var viewModel: ViewModel
    
    init(apiService: ApiServing, user: User) {
        self.apiService = apiService
        self.user = user
        self._viewModel = State(wrappedValue: ViewModel(apiService: apiService, 
                                                        injectedUser: user))
    }
    
    var body: some View {
        VStack {
            FilterBarView()
            
            Spacer()
        }
        .navigationTitle("\(user.username) - \(Int(user.publicRepos ?? 0)) related repos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @State var apiService = ApiService()
    let testAvatar = UIImage(named: "testAvatar")
    let avatarData = testAvatar?.pngData()
    let fakeUser = User(id: 1, username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", url: "https://api.github.com/users/davidmansourian", reposUrl: "", type: "User", publicRepos: 5, avatarImageData: avatarData)
    return NavigationStack{ProfileView(apiService: apiService, user: fakeUser)}
}
