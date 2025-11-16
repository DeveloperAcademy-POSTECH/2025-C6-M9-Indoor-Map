//
//  SearchView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/16/25.
//

import SwiftUI

struct SearchView: View {
    @State var searchText: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    Text("편의 시설")
                        .font(.title3)
                        .foregroundStyle(Color.primary)
                    if searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(AmenityCategory.allCases) { category in
                                Button {
                                    // TODO: 눌렀을때 이동하는 로직
                                } label: {
                                    HStack(alignment: .center, spacing: 10) {
                                        Image(systemName: category.symbolName)
                                            .font(.system(.title2))
                                            .foregroundStyle(category.foregroundColor)
                                            .frame(width: 48, height: 48)
                                            .background(category.backgroundColor)
                                            .clipShape(Circle())

                                        Text(category.displayName)
                                            .font(.body)
                                            .foregroundStyle(Color.primary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("검색")
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
