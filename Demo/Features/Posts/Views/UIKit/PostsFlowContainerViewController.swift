//
//  PostsFlowContainerViewController.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import SnapKit
import UIKit

final class PostsFlowContainerViewController: UIViewController {
    var posts: [Post] = []
    var onReload: () async -> Void = {}

    private let navigation = UINavigationController()
    private let listViewController = PostsListViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        listViewController.onSelect = { [weak self] post in
            guard let self else { return }
            guard let postId = post.id,
                  let index = self.posts.firstIndex(where: { $0.id == postId }) else { return }
            let detail = PostDetailViewController(allPosts: self.posts, startIndex: index)
            self.navigation.pushViewController(detail, animated: true)
        }
        listViewController.onReload = { [weak self] in
            guard let self else { return }
            await self.onReload()
        }

        navigation.setViewControllers([listViewController], animated: false)
        navigation.navigationBar.prefersLargeTitles = false

        addChild(navigation)
        view.addSubview(navigation.view)
        navigation.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        navigation.didMove(toParent: self)

        syncPostsFromViewModel()
    }

    func syncPostsFromViewModel() {
        listViewController.posts = posts
        listViewController.applyPosts()
    }
}
