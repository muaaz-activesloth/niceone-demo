//
//  HTTPURLResponse+Success.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import Foundation

extension HTTPURLResponse {
    /// `true` for 2xx responses (typical REST success range).
    var hasSuccessfulStatusCode: Bool {
        (200 ..< 300).contains(statusCode)
    }
}
