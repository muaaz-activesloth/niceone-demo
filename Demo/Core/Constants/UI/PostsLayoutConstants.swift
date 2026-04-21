//
//  PostsLayoutConstants.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import CoreGraphics

/// Layout metrics and identifiers for Posts UI (UIKit + SnapKit). Not API or business rules.
enum PostsLayoutConstants {
    enum List {
        static let estimatedRowHeight: CGFloat = 88
    }

    enum Cell {
        static let reuseIdentifier = "PostTableViewCell"
        static let verticalPadding: CGFloat = 12
        static let titleBodySpacing: CGFloat = 6
        static let leadingInset: CGFloat = 20
        static let trailingInset: CGFloat = 12
        static let thumbnailSide: CGFloat = 72
        static let thumbnailCornerRadius: CGFloat = 8
        static let imageTextSpacing: CGFloat = 12
    }

    enum Detail {
        static let footerMinHeight: CGFloat = 52
        static let footerButtonVerticalInset: CGFloat = 10
        static let footerHorizontalInset: CGFloat = 16
        static let footerButtonSpacing: CGFloat = 12
        static let contentHorizontalInset: CGFloat = 20
        static let titleTop: CGFloat = 16
        static let titleBodySpacing: CGFloat = 16
        static let bodyMetaSpacing: CGFloat = 20
        static let contentBottom: CGFloat = 24
        static let disabledControlAlpha: CGFloat = 0.45
        static let imageHeight: CGFloat = 220
    }

    enum Root {
        static let loadingOverlayPadding: CGFloat = 12
        static let loadingOverlayCornerRadius: CGFloat = 12
        static let loadingOverlayTopInset: CGFloat = 12
        static let loadingOverlayTrailingInset: CGFloat = 16
        static let loadingTitleOffset: CGFloat = 24
        static let loadingTitleSpacing: CGFloat = 12
        static let placeholderHorizontalInset: CGFloat = 24
        static let placeholderStackSpacing: CGFloat = 12
        static let placeholderIconHeight: CGFloat = 40
    }
}
