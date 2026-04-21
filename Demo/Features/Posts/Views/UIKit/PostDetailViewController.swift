//
//  PostDetailViewController.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import SnapKit
import UIKit

final class PostDetailViewController: UIViewController {
    private var allPosts: [Post]
    private var currentIndex: Int

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let metaLabel = UILabel()
    private let productImage = UIImageView()
    
    private let footerView = UIView()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    init(allPosts: [Post], startIndex: Int) {
        self.allPosts = allPosts
        self.currentIndex = Self.clampedIndex(startIndex, count: allPosts.count)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configureChrome()
        buildLayout()
        applyCurrentPost(animated: false)
    }

    /// Updates backing posts when the shared list changes (e.g. refresh).
    func updateAllPosts(_ posts: [Post], focusedId: Int) {
        allPosts = posts
        if let idx = posts.firstIndex(where: { $0.id == focusedId }) {
            currentIndex = Self.clampedIndex(idx, count: posts.count)
        } else {
            currentIndex = Self.clampedIndex(currentIndex, count: posts.count)
        }
        guard isViewLoaded else { return }
        applyCurrentPost(animated: false)
    }

    private func buildLayout() {
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        titleLabel.font = .preferredBoldFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.numberOfLines = 0
        bodyLabel.adjustsFontForContentSizeCategory = true

        metaLabel.font = .preferredFont(forTextStyle: .subheadline)
        metaLabel.textColor = .secondaryLabel
        metaLabel.adjustsFontForContentSizeCategory = true

        productImage.contentMode = .scaleAspectFit
        productImage.clipsToBounds = true
        productImage.backgroundColor = .secondarySystemBackground

        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(metaLabel)
        contentView.addSubview(productImage)
        
        footerView.backgroundColor = .secondarySystemGroupedBackground
        view.addSubview(footerView)
        footerView.addSubview(previousButton)
        footerView.addSubview(nextButton)

        var previousConfiguration = UIButton.Configuration.bordered()
        previousConfiguration.title = PostsStrings.Detail.previous
        previousConfiguration.titleLineBreakMode = .byTruncatingTail
        previousButton.configuration = previousConfiguration

        var nextConfiguration = UIButton.Configuration.bordered()
        nextConfiguration.title = PostsStrings.Detail.next
        nextConfiguration.titleLineBreakMode = .byTruncatingTail
        nextButton.configuration = nextConfiguration

        previousButton.addAction(UIAction { [weak self] _ in self?.goToAdjacent(-1) }, for: .touchUpInside)
        nextButton.addAction(UIAction { [weak self] _ in self?.goToAdjacent(1) }, for: .touchUpInside)

        footerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.greaterThanOrEqualTo(PostsLayoutConstants.Detail.footerMinHeight)
        }
        previousButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(PostsLayoutConstants.Detail.footerHorizontalInset)
            make.top.bottom.equalToSuperview().inset(PostsLayoutConstants.Detail.footerButtonVerticalInset)
        }
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-PostsLayoutConstants.Detail.footerHorizontalInset)
            make.top.bottom.equalToSuperview().inset(PostsLayoutConstants.Detail.footerButtonVerticalInset)
            make.leading.equalTo(previousButton.snp.trailing).offset(PostsLayoutConstants.Detail.footerButtonSpacing)
            make.width.equalTo(previousButton)
        }

        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(footerView.snp.top)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(PostsLayoutConstants.Detail.titleTop)
            make.leading.trailing.equalToSuperview().inset(PostsLayoutConstants.Detail.contentHorizontalInset)
        }
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(PostsLayoutConstants.Detail.titleBodySpacing)
            make.leading.trailing.equalTo(titleLabel)
        }
        metaLabel.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel.snp.bottom).offset(PostsLayoutConstants.Detail.bodyMetaSpacing)
            make.leading.trailing.equalTo(titleLabel)
        }
        productImage.snp.makeConstraints { make in
            make.top.equalTo(metaLabel.snp.bottom).offset(PostsLayoutConstants.Detail.bodyMetaSpacing)
            make.leading.trailing.equalTo(titleLabel)
            make.height.equalTo(PostsLayoutConstants.Detail.imageHeight)
            make.bottom.equalToSuperview().offset(-PostsLayoutConstants.Detail.contentBottom)
        }
    }

    private func configureChrome() {
        navigationItem.largeTitleDisplayMode = .never
    }

    private func goToAdjacent(_ delta: Int) {
        let next = currentIndex + delta
        guard allPosts.indices.contains(next) else { return }
        currentIndex = next
        applyCurrentPost(animated: true)
    }

    private func applyCurrentPost(animated: Bool) {
        guard allPosts.indices.contains(currentIndex) else { return }
        let post = allPosts[currentIndex]
        navigationItem.title = PostsStrings.Detail.navigationTitle(postId: post.id ?? 0)
        titleLabel.text = post.title
        bodyLabel.text = post.description
        metaLabel.text = PostsStrings.Detail.metaLine(
            category: post.category?.rawValue ?? "unknown",
            rating: post.rating?.rate,
            reviewCount: post.rating?.count
        )
        Task { [weak self] in
            await self?.productImage.setRemoteImage(from: post.image)
        }

        let canGoBack = currentIndex > 0
        let canGoForward = currentIndex < allPosts.count - 1
        previousButton.isEnabled = canGoBack
        nextButton.isEnabled = canGoForward
        let disabledAlpha = PostsLayoutConstants.Detail.disabledControlAlpha
        previousButton.alpha = canGoBack ? 1 : disabledAlpha
        nextButton.alpha = canGoForward ? 1 : disabledAlpha

        let offset = animated ? CGPoint(x: 0, y: -scrollView.adjustedContentInset.top) : .zero
        scrollView.setContentOffset(offset, animated: animated)
    }

    private static func clampedIndex(_ index: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return index.clamped(to: 0 ... (count - 1))
    }
}
