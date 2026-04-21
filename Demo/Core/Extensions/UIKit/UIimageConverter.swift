//
//  UIimageConverter.swift
//  Demo
//
//  Created by MuHa on 21/04/2026.
//

import Foundation
import UIKit

private enum RemoteImageLoader {
    private static let requestCachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad

    static func image(from url: URL) async -> UIImage? {
        let request = URLRequest(url: url, cachePolicy: requestCachePolicy)

        if let cached = URLCache.shared.cachedResponse(for: request),
           let image = UIImage(data: cached.data) {
            return image
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  (200 ... 299).contains(http.statusCode),
                  let image = UIImage(data: data) else {
                return nil
            }

            let cachedResponse = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedResponse, for: request)
            return image
        } catch {
            return nil
        }
    }
}

extension UIImageView {
    @MainActor
    func setRemoteImage(from urlString: String?) async {
        image = nil
        guard let urlString, let url = URL(string: urlString) else { return }
        image = await RemoteImageLoader.image(from: url)
    }
}
