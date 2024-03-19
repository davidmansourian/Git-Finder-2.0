//
//  RepositoryCardViewSkeleton.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-19.
//

import SwiftUI

struct RepositoryCardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Skeletonman")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("View repository")
                    .foregroundStyle(.blue)
            }
            
                Text("This is a skeleton description")
                    .font(.callout)
                    .padding(.vertical, 5)
            
            HStack {
                Image(systemName: "person.crop.circle.badge.questionmark.fill")
                    .foregroundStyle(.gray)
                
                Text("owned by Skeletonman")
                
                Spacer()
                
                Image(systemName: "eye")
                    .foregroundStyle(.gray)
                Text("\(12) watchers")
            }
            .font(.footnote)
            .fontWeight(.ultraLight)
            .padding(.top, 10)
        }
        .redacted(reason: .placeholder)
    }
}

#Preview {
    RepositoryCardSkeletonView()
}
