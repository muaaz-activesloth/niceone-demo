//
//  PostsListViewModel.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import Combine
import Foundation

@MainActor
final class PostsListViewModel: ObservableObject {
    @Published private(set) var posts: [Post] = []
    /// Starts `true` so the first UI frame shows a loading state before `load()` runs.
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?

    private let service: PostAPIService
    private var inflightLoads = 0

    init(service: PostAPIService = PostAPIService()) {
        self.service = service
    }

    func load() async {
        inflightLoads += 1
        isLoading = true
        errorMessage = nil
        defer {
            inflightLoads -= 1
            if inflightLoads == 0 { isLoading = false }
        }

        do {
            posts = try await service.fetchPosts()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
