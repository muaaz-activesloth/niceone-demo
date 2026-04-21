//
//  PostsRootViewController.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import Combine
import SnapKit
import UIKit

final class PostsRootViewController: UIViewController {
    private let viewModel = PostsListViewModel()
    private let contentContainer = UIView()

    private let overlayBackground = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    private let overlaySpinner = UIActivityIndicatorView(style: .medium)

    private var flowViewController: PostsFlowContainerViewController?
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(contentContainer)
        contentContainer.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        view.addSubview(overlayBackground)
        overlayBackground.contentView.addSubview(overlaySpinner)
        overlayBackground.layer.cornerRadius = PostsLayoutConstants.Root.loadingOverlayCornerRadius
        overlayBackground.clipsToBounds = true
        overlayBackground.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(PostsLayoutConstants.Root.loadingOverlayTopInset)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-PostsLayoutConstants.Root.loadingOverlayTrailingInset)
        }
        overlaySpinner.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(PostsLayoutConstants.Root.loadingOverlayPadding)
        }
        overlayBackground.isHidden = true

        viewModel.$posts
            .combineLatest(viewModel.$isLoading, viewModel.$errorMessage)
            .receive(on: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.render()
            }
            .store(in: &cancellables)

        Task { await viewModel.load() }
    }

    private func render() {
        if viewModel.isLoading && viewModel.posts.isEmpty {
            showLoadingPlaceholder()
        } else if let message = viewModel.errorMessage, viewModel.posts.isEmpty {
            showErrorPlaceholder(message: message)
        } else if viewModel.posts.isEmpty {
            showEmptyPlaceholder()
        } else {
            showPostsFlow()
        }

        let showOverlay = viewModel.isLoading && !viewModel.posts.isEmpty
        overlayBackground.isHidden = !showOverlay
        if showOverlay {
            overlaySpinner.startAnimating()
        } else {
            overlaySpinner.stopAnimating()
        }
    }

    private func resetContent() {
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        flowViewController = nil
    }

    private func showLoadingPlaceholder() {
        resetContent()
        let panel = makeCenteredPanel()
        contentContainer.addSubview(panel)
        panel.snp.makeConstraints { $0.edges.equalToSuperview() }

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        let label = UILabel()
        label.text = PostsStrings.List.loading
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0

        panel.addSubview(spinner)
        panel.addSubview(label)
  
        spinner.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-PostsLayoutConstants.Root.loadingTitleOffset)
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(spinner.snp.bottom).offset(PostsLayoutConstants.Root.loadingTitleSpacing)
            make.leading.trailing.equalToSuperview().inset(PostsLayoutConstants.Root.placeholderHorizontalInset)
        }
    }

    private func showErrorPlaceholder(message: String) {
        resetContent()
        let panel = makeCenteredPanel()
        contentContainer.addSubview(panel)
        panel.snp.makeConstraints { $0.edges.equalToSuperview() }

        let icon = UIImageView(image: UIImage(systemName: PostsStrings.List.errorIcon))
        icon.tintColor = .secondaryLabel
        icon.contentMode = .scaleAspectFit

        let title = UILabel()
        title.text = PostsStrings.List.errorTitle
        title.font = .preferredBoldFont(forTextStyle: .title3)
        title.textAlignment = .center
        title.numberOfLines = 0

        let body = UILabel()
        body.text = message
        body.font = .preferredFont(forTextStyle: .body)
        body.textColor = .secondaryLabel
        body.textAlignment = .center
        body.numberOfLines = 0

        var retryConfig = UIButton.Configuration.borderedProminent()
        retryConfig.title = PostsStrings.List.retry
        let retry = UIButton(configuration: retryConfig)
        retry.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            Task { await self.viewModel.load() }
        }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [icon, title, body, retry])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = PostsLayoutConstants.Root.placeholderStackSpacing

        panel.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(PostsLayoutConstants.Root.placeholderHorizontalInset)
        }
        icon.snp.makeConstraints { make in
            make.height.equalTo(PostsLayoutConstants.Root.placeholderIconHeight)
        }
    }

    private func showEmptyPlaceholder() {
        resetContent()
        let panel = makeCenteredPanel()
        contentContainer.addSubview(panel)
        panel.snp.makeConstraints { $0.edges.equalToSuperview() }

        let icon = UIImageView(image: UIImage(systemName: PostsStrings.List.emptyIcon))
        icon.tintColor = .secondaryLabel
        icon.contentMode = .scaleAspectFit

        let title = UILabel()
        title.text = PostsStrings.List.emptyTitle
        title.font = .preferredBoldFont(forTextStyle: .title3)
        title.textAlignment = .center
        title.numberOfLines = 0

        let body = UILabel()
        body.text = PostsStrings.List.emptyDescription
        body.font = .preferredFont(forTextStyle: .body)
        body.textColor = .secondaryLabel
        body.textAlignment = .center
        body.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [icon, title, body])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = PostsLayoutConstants.Root.placeholderStackSpacing

        panel.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(PostsLayoutConstants.Root.placeholderHorizontalInset)
        }
        icon.snp.makeConstraints { make in
            make.height.equalTo(PostsLayoutConstants.Root.placeholderIconHeight)
        }
    }

    private func showPostsFlow() {
        if flowViewController == nil {
            resetContent()
            let flow = PostsFlowContainerViewController()
            addChild(flow)
            contentContainer.addSubview(flow.view)
            flow.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            flow.didMove(toParent: self)
            flowViewController = flow
        }
        guard let flow = flowViewController else { return }
        flow.posts = viewModel.posts
        flow.onReload = { [weak self] in
            guard let self else { return }
            await self.viewModel.load()
        }
        flow.syncPostsFromViewModel()
    }

    private func makeCenteredPanel() -> UIView {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
}
