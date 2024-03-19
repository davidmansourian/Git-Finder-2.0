//
//  FilterBarView.swift
//  New-GitHub
//
//  Created by David Mansourian on 2024-03-17.
//

import SwiftUI

struct FilterBarView: View {
    @Binding var filterState: FilterState
    @Namespace var animation
    
    var body: some View {
        HStack {
            ForEach(FilterState.allCases, id: \.rawValue) { tab in
                VStack {
                    Text(tab.title)
                        .font(.subheadline)
                        .fontWeight(filterState == tab ? .semibold : .regular)
                        .foregroundStyle(filterState == tab ? Color.primary : .gray)
                    
                    if filterState == tab {
                        Capsule()
                            .foregroundStyle(.blue)
                            .opacity(0.5)
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "filter", in: animation)
                    } else {
                        Capsule()
                            .foregroundStyle(.clear)
                            .frame(height: 3)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        filterState = tab
                    }
                }
            }
        }
    }
}

#Preview {
    FilterBarView(filterState: .constant(.all))
}
