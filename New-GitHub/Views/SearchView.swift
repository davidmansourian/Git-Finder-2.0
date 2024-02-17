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
    
    @State private var searchTerm = ""
    @State private var viewModel: ViewModel
    
    init(apiService: ApiServing) {
        self.apiService = apiService
        self._viewModel = State(wrappedValue: ViewModel(apiService: apiService))
    }

    var body: some View {
        NavigationStack {
            switch viewModel.viewState {
            case .idle:
                usersList
            case .loading:
                loadingList
            case .error(let error):
                Text(error)
            }
        }
        .searchable(text: $searchTerm)
        .onChange(of: searchTerm) {
            viewModel.cancelSearchTask()
            
            Task {
                await viewModel.handleSearch(for: searchTerm)
            }
        }
    }
}

extension SearchView {
    private var usersList: some View {
        Group {
            if let users = viewModel.users {
                List(users, id: \.username) { user in
                    ProfileResultItemView(user: user)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            } else {
                // Show search history
            }
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
}

#Preview {
    @State var apiService = ApiService()
    return SearchView(apiService: apiService)
}
//
