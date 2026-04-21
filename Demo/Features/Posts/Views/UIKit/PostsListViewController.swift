//
//  PostsListViewController.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import SnapKit
import UIKit

final class PostsListViewController: UIViewController {
    var posts: [Post] = []
    var onSelect: ((Post) -> Void)?
    /// Wired from the root coordinator; drives refresh control and nav bar refresh.
    var onReload: (() async -> Void)?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addAction(UIAction { [weak self] _ in
            Task { await self?.performReload() }
        }, for: .valueChanged)
        return control
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = PostsStrings.List.navigationTitle

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = PostsLayoutConstants.List.estimatedRowHeight
        tableView.refreshControl = refreshControl
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostsLayoutConstants.Cell.reuseIdentifier)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        applyPosts()
    }

    func applyPosts() {
        tableView.reloadData()
        syncReloadChrome()
    }

    private func syncReloadChrome() {
        guard let onReload else {
            navigationItem.rightBarButtonItem = nil
            tableView.refreshControl = nil
            return
        }
        tableView.refreshControl = refreshControl
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .refresh,
            primaryAction: UIAction { [weak self] _ in
                Task { await self?.performReload() }
            }
        )
    }

    private func performReload() async {
        await onReload?()
        await MainActor.run {
            refreshControl.endRefreshing()
        }
    }
}

extension PostsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PostsLayoutConstants.Cell.reuseIdentifier,
            for: indexPath
        ) as? PostTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }
}

extension PostsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelect?(posts[indexPath.row])
    }
}
