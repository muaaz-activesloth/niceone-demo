//
//  PostsStrings.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import Foundation

/// User-facing copy for the Posts feature. Separate from `PostAPIConstants` so presentation text stays out of networking.
enum PostsStrings {
    enum List {
        static let loading = "Loading posts…"
        static let navigationTitle = "Posts"
        static let errorTitle = "Couldn’t load posts"
        static let errorIcon = "wifi.exclamationmark"
        static let retry = "Retry"
        static let emptyTitle = "No posts"
        static let emptyIcon = "doc.text"
        static let emptyDescription = "Pull to refresh or try again later."
    }

    enum Detail {
        static let previous = "Previous"
        static let next = "Next"
        static func navigationTitle(postId: Int) -> String {
            "Product \(postId)"
        }

        static func metaLine(category: String, rating: Double?, reviewCount: Int?) -> String {
            let ratingText = rating.map { String(format: "%.1f", $0) } ?? "n/a"
            let reviewsText = reviewCount.map(String.init) ?? "0"
            return "\(category.capitalized) • \(ratingText) (\(reviewsText) reviews)"
        }
    }
}
