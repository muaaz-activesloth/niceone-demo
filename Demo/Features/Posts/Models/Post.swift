//
//  Post.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import Foundation

/// A lightweight model for JSONPlaceholder's `/posts` resource.
struct PostElement: Codable, Sendable {
    let id: Int?
    let title: String?
    let price: Double?
    let description: String?
    let category: Category?
    let image: String?
    let rating: Rating?
}

enum Category: String, Codable, Sendable {
    case electronics = "electronics"
    case jewelery = "jewelery"
    case menSClothing = "men's clothing"
    case womenSClothing = "women's clothing"
}

// MARK: - Rating
struct Rating: Codable, Sendable {
    let rate: Double?
    let count: Int?
}

typealias Post = PostElement
