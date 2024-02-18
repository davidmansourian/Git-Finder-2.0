//
//  LoadingResultItemView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-02-17.
//

import SwiftUI

struct LoadingListemItemView: View {
    var body: some View {
        HStack {
            Circle()
                .foregroundStyle(.gray)
                .opacity(0.4)
                .frame(width: 32, height: 32)
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.gray)
                .opacity(0.4)
                .frame(width: 100, height: 12)
        }
        .shimmering(active: true)
    }
}

#Preview {
    LoadingListemItemView()
}
