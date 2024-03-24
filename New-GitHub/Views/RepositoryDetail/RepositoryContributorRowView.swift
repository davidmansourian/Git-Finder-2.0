//
//  RepositoryContributorsListView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import SwiftUI

struct RepositoryContributorRowView: View {
    let username: String
    let contributions: Int
    let image: UIImage?
    var body: some View {
        HStack{
            avatarImage(width: 30, height: 30, avatarImage: image)
            
            Text(username)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(contributions) contributions")
                .font(.subheadline)
                .fontWeight(.thin)
                .padding(.trailing)
                .foregroundColor(.primary)
        }
    }
}

extension RepositoryContributorRowView {
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
    let mockImage = UIImage(named: "testAvatar")
    return RepositoryContributorRowView(username: "Test", contributions: 10, image: mockImage)
}
