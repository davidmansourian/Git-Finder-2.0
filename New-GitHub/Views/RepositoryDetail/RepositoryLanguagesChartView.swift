//
//  RepositoryLanguagesChartView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-24.
//

import Charts
import SwiftUI

struct RepositoryLanguagesChartView: View {
    @Environment(\.colorScheme) private var colorScheme
    let repoLanguages: [RepoLanguage]
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
    let hexColor = "00ADD8FF"
    let color = Color.init(hex: hexColor) ?? .red
    let language = RepoLanguage(language: "Go", percentage: 100.0, color: color)
    return RepositoryLanguagesChartView(repoLanguages: [language])
}
