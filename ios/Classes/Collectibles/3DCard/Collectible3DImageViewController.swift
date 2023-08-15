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

//   Collectible3DImageViewController.swift

import UIKit
import SceneKit
import MacaroonUIKit
import MacaroonUtils

final class Collectible3DImageViewController:
    BaseViewController,
    Collectible3DCardDisplayable {
    var sceneMaterial: SCNMaterial?
    var sceneView: SCNView?
    let renderContext = CIContext(
        options: [.useSoftwareRenderer: false]
    )

    private lazy var theme = Collectible3DViewerTheme()

    private lazy var closeButton = UIButton(type: .custom)
    private lazy var imageView = UIImageView(image: image)

    private let image: UIImage
    private let rendersContinuously: Bool

    init(
        image: UIImage,
        rendersContinuously: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.image = image
        self.rendersContinuously = rendersContinuously
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        add3DImageCard()
    }

    override func setListeners() {
        super.setListeners()
        closeButton.addTarget(
            self,
            action: #selector(didTapCloseButton),
            for: .touchUpInside
        )
    }
}

extension Collectible3DImageViewController {
    private func add3DImageCard() {
        sceneView = composeSceneView(on: view)
        sceneMaterial = composeSceneMaterial()

        let aView = view

        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            guard let self = self,
                  let aView = aView else {
                      return
                  }

            self.setupBlurredBackground(
                from: self.image,
                to: aView
            )

            self.addSceneView()
        }
    }

    private func addSceneView() {
        setupScene(for: image.size)

        asyncMain {
            [weak self] in
            guard let self = self else { return }

            if let sceneView = self.sceneView {
                self.view.addSubview(sceneView)
            }

            self.applyImageFilters()
            self.addCloseButton()
            self.animateGroupNode()
        }
    }

    private func applyImageFilters() {
        guard let material = sceneMaterial else {
            return
        }

        if let ciImage = CIImage(image: image) {
            let grayscale = ciImage.applyingFilter(
                "CIColorControls",
                parameters: [
                    kCIInputSaturationKey: 0.0,
                    kCIInputContrastKey: 100.0
                ]
            )

            if let metalImage = renderContext.createCGImage(grayscale, from: grayscale.extent) {
                material.metalness.contents = metalImage
                material.metalness.intensity = 0.4
            }

            let noirImage = ciImage.applyingFilter("CIPhotoEffectNoir")

            if let roughImage = renderContext.createCGImage(noirImage, from: noirImage.extent) {
                material.roughness.contents = roughImage
                material.roughness.intensity = 0.4
            }
        }

        sceneView?.rendersContinuously = rendersContinuously

        material.diffuse.contents = imageView.layer
    }

    private func addCloseButton() {
        closeButton.customizeAppearance(theme.close)

        view.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.leading == theme.buttonLeadingPadding
            $0.top == theme.buttonTopPadding
            $0.fitToSize(theme.butonSize)
        }
    }
}

extension Collectible3DImageViewController {
    @objc
    private func didTapCloseButton() {
        dismissScreen()
    }
}
