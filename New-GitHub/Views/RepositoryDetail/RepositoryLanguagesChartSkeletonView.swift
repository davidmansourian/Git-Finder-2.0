//
//  RepositoryLanguagesChartSkeletonView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import Charts
import SwiftUI

struct RepositoryLanguagesChartSkeletonView: View {
    @Environment(\.colorScheme) private var colorScheme
    let repoLanguage1 = RepoLanguage(language: "Swift", percentage: 50, color: .gray)
    let repoLanguage2 = RepoLanguage(language: "C++", percentage: 25, color: .gray)
    let repoLanguage3 = RepoLanguage(language: "Go", percentage: 10, color: .gray)
    let repoLanguage4 = RepoLanguage(language: "Python", percentage: 8, color: .gray)
    let repoLanguage5 = RepoLanguage(language: "Java", percentage: 7, color: .gray)
    
    let repoLanguages: [RepoLanguage]
    
    init() {
        self.repoLanguages = [repoLanguage1, repoLanguage2, repoLanguage3, repoLanguage4, repoLanguage5]
    }
    
    var body: some View {
        Chart(repoLanguages, id: \.self){ language in
                BarMark(
                    x: .value("Percentage", Int(language.percentage)),
                    y: .value("Language", language.language )
                )
                .foregroundStyle(language.color)
                .annotation(position: .trailing, alignment: .center) {
                    Text(String(format: "%.2f%%",language.percentage))
                        .foregroundColor(.primary)
                        .font(.caption2)
                }
        }
        .redacted(reason: .placeholder)
        .shimmering()
        .padding()
        .frame(height: 350)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(radius: 2)
        )
        .padding(.horizontal, 10)
        .padding(.top, 5)
    }
}


#Preview {
    RepositoryLanguagesChartSkeletonView()
}
