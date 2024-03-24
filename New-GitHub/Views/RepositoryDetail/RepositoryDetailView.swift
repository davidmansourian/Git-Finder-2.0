//
//  RepositoryDetailView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import SafariServices
import SwiftUI

struct RepositoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let apiService: ApiServing
    let repository: Repository
    let avatarLoader: AvatarLoader
    let image: UIImage?
    
    @State private var showContributors = false
    @State private var showSafari = false
    @State private var viewModel: ViewModel
    
    init(apiService: ApiServing, repository: Repository, avatarLoader: AvatarLoader, image: UIImage?) {
        self.apiService = apiService
        self.repository = repository
        self.avatarLoader = avatarLoader
        self.image = image
        
        self._viewModel = State(
            wrappedValue: ViewModel(
                apiService: apiService,
                avatarLoader: avatarLoader,
                username: repository.owner.username,
                repositoryName: repository.name
            )
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            titleAndDismissButtonView
            
            ScrollView {
                if let description = repository.description {
                    usernameAndAvatarView
                    
                    descriptionAndStatsView(description: description)
                } else {
                    HStack {
                        usernameAndAvatarView
                        
                        Spacer()
                        
                        statsView
                    }
                }
                
                languagesChartView
                
                
                contributorsAndReadmeButtonsView
                
                Spacer()
            }
        }
        .sheet(isPresented: $showContributors) {
            contributorsListView
        }
        .fullScreenCover(isPresented: $showSafari) {
            if let url = viewModel.readmeUrl(for: repository.name, defaultBranch: repository.defaultBranch) {
                SFSafariView(url: url)
            }
        }
    }
}

private extension RepositoryDetailView {
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
    
    var titleAndDismissButtonView: some View {
        HStack {
            Text(repository.name)
                .font(.title2)
                .fontWeight(.light)
                .padding(.leading)
                .padding(.top)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .padding(.trailing)
            .offset(y: 10)
        }
    }
    
    var usernameAndAvatarView: some View {
        HStack {
            Text("by \(repository.owner.username)")
                .fontWeight(.ultraLight)
                .padding(.leading)
            
            avatarImage(width: 18, height: 18, avatarImage: image)
            
            Spacer()
        }
    }
    
    func descriptionAndStatsView(description: String) -> some View {
        HStack {
            Text(description)
                .font(.caption)
                .fontWeight(.light)
                .padding(.horizontal)
                .padding(.top, 1)
            
            Spacer()
            
            statsView
        }
    }
    
    var statsView: some View {
        Group {
            Label(String(repository.watchersCount), systemImage: "eye")
            Label(String(repository.starGazersCount), systemImage: "star")
            Label(String(repository.forksCount), systemImage: "tuningfork")
                .padding(.trailing)
        }
        .font(.caption)
        .fontWeight(.light)
    }
    
    var languagesChartView: some View {
        Group {
            switch viewModel.languageLoadingState {
            case .loading:
                RepositoryLanguagesChartSkeletonView()
            case .loaded(let languages):
                RepositoryLanguagesChartView(repoLanguages: languages)
            case .error:
                EmptyView()
            }
            
        }
        .padding(.top, 10)
    }
    
    var contributorsAndReadmeButtonsView: some View {
        Group {
            switch viewModel.contributorLoadingState {
            case .loading:
                RepositoryContributorsAndReadmeSkeletonView()
            case .loaded(_):
                HStack(spacing: 100) {
                    contributorsButtonView

                    readmeButtonView
                }
            case .error:
                readmeButtonView
            }
        }
        .padding(.top, 30)
    }
    
    @ViewBuilder
    var contributorsButtonView: some View {
        if let topContributorsAvatars = viewModel.topContributorImages() {
            VStack {
                ZStack {
                    ForEach(topContributorsAvatars) { instance in
                        avatarImage(width: 40, height: 40, avatarImage: instance.avatar)
                            .offset(x: CGFloat(instance.id*10))
                    }
                }
                
                
                Text("Contributors")
                    .foregroundStyle(.blue)
            }
            .onTapGesture { showContributors.toggle() }
        } else {
            EmptyView()
        }
    }
    
    var readmeButtonView: some View {
        VStack(spacing: 4) {
            Image(systemName: "doc")
                .font(.system(size: 40))
            
            
            Text("Read me")
                .foregroundStyle(.blue)
        }
        .onTapGesture { showSafari.toggle() }
    }
    
    var contributorsListView: some View {
        VStack {
            Text("Top contributors")
                .font(.callout)
                .fontWeight(.light)
                .padding()
            
            List(viewModel.contributors, id: \.self) { contributor in
                RepositoryContributorRowView(username: contributor.username, contributions: contributor.contributions, image: viewModel.contributorsAvatars[contributor.username])
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    let mockImage = UIImage(named: "testAvatar")
    let mockRepoOwner = Repository.Owner(username: "Pelle", avatarUrl: "https://avatars.githubusercontent.com/u/112928485?v=4")
    let mockRepository = Repository(name: "Pelle's Project", owner: mockRepoOwner, description: "I am Pelle. This is my project, and I am very proud of it.", starGazersCount: 120, watchersCount: 33, forksCount: 25, lastUpdated: "2023-09-05T22:41:23Z", defaultBranch: "main")
    
    let cacheManager = MockCacheManager()
    let apiService = MockApiService(cacheManager: cacheManager)
    let avatarLoader = AvatarLoader(apiService: apiService)
    
    return RepositoryDetailView(apiService: apiService, repository: mockRepository, avatarLoader: avatarLoader, image: mockImage)
}
