//
//  SearchResultItemSkeletonView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-17.
//

import SwiftUI

struct SearchResultItemSkeletonView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack {
            Circle()
                .foregroundStyle(colorScheme == .light ? .gray : .white)
                .opacity(0.5)
                .frame(width: 32, height: 32)
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(colorScheme == .light ? .gray : .white)
                .opacity(0.4)
                .frame(width: 80, height: 9)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(colorScheme == .light ? .gray : .white)
                .opacity(0.4)
                .frame(width: 50, height: 8)
            
            Image(systemName: "chevron.right")
                .font(.footnote)
        }
    }
}

#Preview {
    SearchResultItemSkeletonView()
}
