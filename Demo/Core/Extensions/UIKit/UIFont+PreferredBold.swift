//
//  UIFont+PreferredBold.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import UIKit

extension UIFont {
    /// Preferred font for Dynamic Type with bold traits when available.
    static func preferredBoldFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        let base = UIFont.preferredFont(forTextStyle: textStyle)
        guard let boldDescriptor = base.fontDescriptor.withSymbolicTraits(.traitBold) else {
            return base
        }
        return UIFont(descriptor: boldDescriptor, size: base.pointSize)
    }
}
