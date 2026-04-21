//
//  PostAPIConstants.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import Foundation

/// Central API configuration
enum APIConfig {
    static let baseURL = URL(string: "https://fakestoreapi.com/products")!
}

/// Represents all API endpoints in a scalable way
enum APIEndpoint {
    
    // MARK: - Cases
    
    case posts
    case post(id: Int)
    case comments(postId: Int)
    case users
    
    // MARK: - Path
    
    var path: String {
        switch self {
        case .posts:
            return "posts"
        case .post(let id):
            return "posts/\(id)"
        case .comments:
            return "comments"
        case .users:
            return "users"
        }
    }
    
    // MARK: - Query Parameters
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .comments(let postId):
            return [URLQueryItem(name: "postId", value: "\(postId)")]
        default:
            return nil
        }
    }
    
    // MARK: - URL Builder
    
    var url: URL {
        var components = URLComponents(
            url: APIConfig.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        
        components.queryItems = queryItems
        return components.url!
    }
}
