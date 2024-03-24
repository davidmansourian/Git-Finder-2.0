//
//  SearchHistoryItemView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import SwiftData
import SwiftUI

struct SearchHistoryItemView: View {
    let searchHistoryManager: SearchHistoryManager
    let historyInstance: SearchHistory
    let avatarData: Data?
    
    var body: some View {
        HStack {
            avatarImage
            
            Text(historyInstance.username)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button {
                searchHistoryManager.remove(historyInstance)
            } label: {
                Image(systemName: "xmark")
                    .font(.footnote)
            }
            .foregroundStyle(.gray)
            
        }
        .font(.footnote)
    }
}

extension SearchHistoryItemView {
    var avatarImage: some View {
        if let avatarData = self.avatarData,
           let avatarUiImage = UIImage(data: avatarData){
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
    let user = User(id: 1, username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4", url: "https://api.github.com/users/davidmansourian", reposUrl: "", type: "User")
    let historyInstance = SearchHistory(username: user.username, lastVisited: .now, avatarData: testAvatar?.pngData() ?? Data())
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SearchHistory.self, configurations: config)
    
    @State var searchHistoryManager = SearchHistoryManager(modelContext: container.mainContext)
    
    return SearchHistoryItemView(
        searchHistoryManager: searchHistoryManager,
        historyInstance: historyInstance,
        avatarData: testAvatar?.pngData() ?? Data()
    )
}
