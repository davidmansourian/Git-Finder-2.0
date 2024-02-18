//
//  LoadingResultItemView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-17.
//

import SwiftUI

struct LoadingListemItemView: View {
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
                .frame(width: 80, height: 10)
        }
    }
}

#Preview {
    LoadingListemItemView()
}
