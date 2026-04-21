//
//  PostAPIService.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import Foundation

actor PostAPIService {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()

    func fetchPosts() async throws -> [Post] {
        let url = APIConfig.baseURL
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard await http.hasSuccessfulStatusCode else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode([Post].self, from: data)
    }
}

