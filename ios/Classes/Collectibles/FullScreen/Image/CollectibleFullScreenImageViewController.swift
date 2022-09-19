// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CollectibleFullScreenImageViewController.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class CollectibleFullScreenImageViewController:
    FullScreenContentViewController {
    private(set) lazy var imageView = URLImageView()

    private let draft: CollectibleFullScreenImageDraft

    init(
        draft: CollectibleFullScreenImageDraft,
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()

        addImage()
    }

    override func setListeners() {
        super.setListeners()

        isZoomingEnabled = false
    }

    override func bindData() {
        super.bindData()

        let width = view.frame.width.float()

        let viewModel = CollectibleFullScreenImageViewModel(
            draft: draft,
            expectedImageSize: CGSize((width, width))
        )

        imageView.load(from: viewModel.imageSource) {
            [weak self] _ in
            guard let self = self else {
                return
            }

            self.isZoomingEnabled = true
        }
    }
}

extension CollectibleFullScreenImageViewController {
    private func addImage() {
        imageView.build(URLImageViewNoStyleLayoutSheet())
        imageView.imageContainer.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges == 0
        }
    }
}
