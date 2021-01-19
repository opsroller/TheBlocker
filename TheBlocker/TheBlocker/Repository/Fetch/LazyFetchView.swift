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
                    Spacer()
                }
            }
            if viewStore.items.count >= viewStore.fetchLimit
                && viewStore.fetchLimit > 0 {
                HStack {
                    Spacer()
                    if viewStore.isFetching {
                        ProgressView()
                    }
                    Spacer()
                }
                    .onAppear(perform: { viewStore.send(FetchRepositoryAction<Model>.fetchMore) })
            }
        }
    }
}
