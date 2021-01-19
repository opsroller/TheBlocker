//
//  LazyFetchView.swift
//  TheBlocker
//
//  Created by Andrew Roan on 1/17/21.
//

import SwiftUI
import ComposableArchitecture

struct LazyFetch<Model: UnmanagedModel>: View {
    let store: Store<FetchRepositoryState<Model>, FetchRepositoryAction<Model>>

    var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.isFetching {
                HStack {
                    Spacer()
                    ProgressView()
                        .frame(width: 50, height: 50, alignment: .center/*@END_MENU_TOKEN@*/)
                    Spacer()
                }
            }
            if viewStore.items.count >= viewStore.fetchLimit
                && viewStore.fetchLimit > 0 {
                HStack {
                    Spacer()
                    if viewStore.isFetching {
                        ProgressView()
                            .frame(width: 50, height: 50, alignment: .center/*@END_MENU_TOKEN@*/)
                    }
                    Spacer()
                }
                    .onAppear(perform: { viewStore.send(FetchRepositoryAction<Model>.fetchMore) })
            }
        }
    }
}
