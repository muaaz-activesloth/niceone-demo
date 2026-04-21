//
//  PostTableViewCell.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import SnapKit
import UIKit

final class PostTableViewCell: UITableViewCell {
    static let reuseIdentifier = PostsLayoutConstants.Cell.reuseIdentifier

    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let productImage = UIImageView()
    private var imageLoadTask: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        accessoryType = .disclosureIndicator

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontForContentSizeCategory = true

        bodyLabel.font = .preferredFont(forTextStyle: .subheadline)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 2
        bodyLabel.adjustsFontForContentSizeCategory = true

        productImage.contentMode = .scaleAspectFit
        productImage.layer.cornerRadius = PostsLayoutConstants.Cell.thumbnailCornerRadius
        productImage.clipsToBounds = true
        productImage.backgroundColor = .secondarySystemBackground

        let textStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        textStack.axis = .vertical
        textStack.spacing = PostsLayoutConstants.Cell.titleBodySpacing

        contentView.addSubview(productImage)
        contentView.addSubview(textStack)

        productImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(PostsLayoutConstants.Cell.leadingInset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(PostsLayoutConstants.Cell.thumbnailSide)
            make.top.greaterThanOrEqualToSuperview().offset(PostsLayoutConstants.Cell.verticalPadding)
            make.bottom.lessThanOrEqualToSuperview().offset(-PostsLayoutConstants.Cell.verticalPadding)
        }
        textStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(PostsLayoutConstants.Cell.verticalPadding)
            make.leading.equalTo(productImage.snp.trailing).offset(PostsLayoutConstants.Cell.imageTextSpacing)
            make.trailing.equalToSuperview().offset(-PostsLayoutConstants.Cell.trailingInset)
            make.bottom.equalToSuperview().offset(-PostsLayoutConstants.Cell.verticalPadding)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        productImage.image = nil
    }

    func configure(with post: Post) {
        titleLabel.text = post.title
        bodyLabel.text = "$\(post.price ?? 0)"
        imageLoadTask?.cancel()
        imageLoadTask = Task { [weak self] in
            await self?.productImage.setRemoteImage(from: post.image)
        }
    }
}
