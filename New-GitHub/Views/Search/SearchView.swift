//
//  ContentView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-07.
//

import SwiftData
import SwiftUI

struct SearchView: View {
    private let apiService: ApiServing
    
    @State private var path = NavigationPath()
    @State private var viewModel: ViewModel
    @State private var searchTerm = ""
    
    init(apiService: ApiServing) {
        self.apiService = apiService
        self._viewModel = State(wrappedValue: ViewModel(apiService: apiService))
        
        print("did init view")
    }

    var body: some View {
        NavigationStack(path: $path) {
            switch viewModel.viewState {
            case .idle:
                /// Search history
                usersList([])
            case .loading:
                loadingList
            case .loaded(let users):
                if !users.isEmpty {
                    usersList(users)
                } else {
                    Text("No users found")
                        .font(.largeTitle)
                        .fontWeight(.light)
                }
            case .error(let error):
                errorView(error)
            }
        }
        .searchable(text: $searchTerm)
        .onChange(of: searchTerm) {
            viewModel.cancelSearchTask()
            callSearch()
        }
    }
}

extension SearchView {
    private func callSearch() {
        Task {
            await viewModel.handleSearch(for: searchTerm)
        }
    }
    
    private func usersList(_ users: [User]) -> some View {
        List(users, id: \.username) { user in
            NavigationLink(value: user) {
                ProfileResultItemView(user: user)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationDestination(for: User.self) { user in
            ProfileView(apiService: apiService, user: user)
        }
    }
    
    private var loadingList: some View {
        List(1...15, id: \.self) { _ in
            LoadingListemItemView()
                .listRowSeparator(.hidden)
        }
        .shimmering()
        .listStyle(.plain)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            Text(error)
                .fontWeight(.light)
            
            Button(action: {callSearch()}) {
                Image(systemName: "arrow.clockwise")
                    .font(.largeTitle)
                    .fontWeight(.light)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    @State var apiService = ApiService()
    return SearchView(apiService: apiService)
}
//
