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

//   LoadingScreen.swift

import MacaroonUIKit
import UIKit

final class LoadingScreen: BaseViewController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var imageBackgroundView = UIView()
    private lazy var imageView = LottieImageView()
    private lazy var titleView = UILabel()
    private lazy var detailView = UILabel()

    private let viewModel: LoadingScreenViewModel
    private let theme: LoadingScreenTheme

    init(
        viewModel: LoadingScreenViewModel,
        theme: LoadingScreenTheme,
        configuration: ViewControllerConfiguration
    ) {
        self.viewModel = viewModel
        self.theme = theme
        super.init(configuration: configuration)

        isModalInPresentation = true
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        hidesCloseBarButtonItem = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventHandler?(.willStartLoading)
        imageView.play(with: LottieImageView.Configuration())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventHandler?(.didStartLoading)
        setPopGestureEnabled(false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.stop()
        eventHandler?(.didStopLoading)
        setPopGestureEnabled(true)
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeAppearance(theme.background)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addTitle()
        addImageBackground()
        addImage()
        addDetail()
    }

    override func bindData() {
        super.bindData()

        if let image = viewModel.imageName {
            imageView.setAnimation(image)
        }

        viewModel.title?.load(in: titleView)
        viewModel.detail?.load(in: detailView)
    }

    override func didTapBackBarButton() -> Bool {
        return false
    }
}

extension LoadingScreen {
    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        view.addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.centerX == 0
            $0.centerY.equalToSuperview().offset(theme.titleCenterOffset)
            $0.leading == theme.titleHorizontalInset
            $0.trailing == theme.titleHorizontalInset
        }
    }

    private func addImageBackground() {
        imageBackgroundView.customizeAppearance(theme.imageBackground)
        imageBackgroundView.layer.draw(corner: theme.imageBackgroundCorner)

        view.addSubview(imageBackgroundView)
        imageBackgroundView.fitToIntrinsicSize()
        imageBackgroundView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.centerX == 0
            $0.bottom == titleView.snp.top - theme.spacingBetweenImageAndTitle
        }
    }

    private func addImage() {
        imageBackgroundView.addSubview(imageView)
        imageView.fitToIntrinsicSize()
        imageView.snp.makeConstraints {
            $0.setPaddings(theme.imagePaddings)
        }
    }

    private func addDetail() {
        detailView.customizeAppearance(theme.detail)

        view.addSubview(detailView)
        detailView.fitToIntrinsicSize()
        detailView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndDetail
            $0.leading == theme.detailHorizontalInset
            $0.trailing == theme.detailHorizontalInset
        }
    }
}

extension LoadingScreen {
    private func setPopGestureEnabled(_ isEnabled: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
    }
}

extension LoadingScreen {
    enum Event {
        case willStartLoading
        case didStartLoading
        case didStopLoading
    }
}
