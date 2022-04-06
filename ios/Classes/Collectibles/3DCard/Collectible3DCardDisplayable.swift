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

//   Collectible3DCardDisplayable.swift

import SceneKit
import UIKit
import MacaroonUIKit
import MacaroonUtils

protocol Collectible3DCardDisplayable: AnyObject {
    var sceneMaterial: SCNMaterial? { get set }
    var sceneView: SCNView? { get set }
    var renderContext: CIContext { get }

    func composeSceneView(
        on view: UIView
    ) -> SCNView
    func composeSceneMaterial() -> SCNMaterial
    func setupBlurredBackground(
        from image: UIImage,
        to view: UIView
    )
    func setupScene(
        for size: CGSize
    )
    func animateGroupNode()
}

extension Collectible3DCardDisplayable {
    func composeSceneView(
        on view: UIView
    ) -> SCNView {
        let aSceneView = SCNView(frame: view.frame)
        aSceneView.antialiasingMode = .multisampling4X
        aSceneView.backgroundColor = UIColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 0.25
        )
        aSceneView.allowsCameraControl = true
        aSceneView.autoenablesDefaultLighting = true
        return aSceneView
    }

    func composeSceneMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        return material
    }

    func setupBlurredBackground(
        from image: UIImage,
        to view: UIView
    ) {
        if let blurredImage = createBlurredImage(from: image) {
            asyncMain {
                [weak self] in
                guard let self = self else { return }

                let backgroundImageView = UIImageView(image: UIImage(cgImage: blurredImage))
                self.addBackgroundImageView(
                    backgroundImageView,
                    to: view
                )
            }
        }
    }

    func setupScene(
        for size: CGSize
    ) {
        let scene = SCNScene()
        self.sceneView?.scene = scene

        let cardSize = getCardSize(size)
        let cardPath = setupCardPath(from: cardSize)
        let cardBox = composeCardBox(from: cardPath)
        let cardNode = SCNNode(geometry: cardBox)

        let peraLogoPath = composePeraLogoPath()
        let peraLogoShape = SCNShape(
            path: peraLogoPath,
            extrusionDepth: 0.2
        )
        let logoMaterial = composeLogoMaterial()
        peraLogoShape.materials = [logoMaterial, logoMaterial, logoMaterial]
        let peraLogoNode = composePeraLogoNode(from: peraLogoShape)

        let groupNode = composeGroupNode(
            from: cardNode,
            and: peraLogoNode
        )

        scene.rootNode.addChildNode(groupNode)

        addSceneToCameraNode(scene)
    }

    func animateGroupNode() {
        guard let groupNode = sceneView?.scene?.rootNode.childNode(
            withName: Collectible3DCardDisplayableConstants.groupNode.rawValue,
            recursively: true
        ) else {
            return
        }

        groupNode.addAnimation(
            getSpinAnimation(),
            forKey: "initial_spin"
        )
    }
}

extension Collectible3DCardDisplayable {
    private func createBlurredImage(
        from image: UIImage
    ) -> CGImage? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }

        let downsampleScale = 512.0 / max(image.size.width, image.size.height)
        let blurredImage = ciImage
            .clampedToExtent()
            .applyingGaussianBlur(sigma: 100.0)
            .cropped(to: ciImage.extent)
            .transformed(by: CGAffineTransform(scaleX: downsampleScale, y: downsampleScale))

        return renderContext.createCGImage(
            blurredImage,
            from: blurredImage.extent
        )
    }

    private func addBackgroundImageView(
        _ imageView: UIImageView,
        to view: UIView
    ) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill

        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top == 0
            $0.centerX.equalToSuperview()
            $0.bottom == 0
        }
    }
}

extension Collectible3DCardDisplayable {
    private func getCardSize(
        _ size: CGSize
    ) -> CGSize {
        var cardSize = CGSize(
            width: 5,
            height: 5
        )

        if size.width > size.height {
            cardSize.height = 5 * size.height / size.width
        } else if size.height > size.width {
            cardSize.width = 5 * size.width / size.height
        }

        return cardSize
    }

    private func setupCardPath(
        from size: CGSize
    ) -> UIBezierPath {
        let path = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(
                    x: -1 * (size.width / 2),
                    y: -1 * (size.height / 2)
                ),
                size: size
            ),
            cornerRadius: 0.5
        )

        path.flatness = 0.01
        return path
    }

    private func composePeraLogoPath() -> UIBezierPath {
        var peraLogoPath = UIBezierPath()
        composeFirstPeraLogoItemPath(&peraLogoPath)
        composeSecondPeraLogoItemPath(&peraLogoPath)
        composeThirdPeraLogoItemPath(&peraLogoPath)
        composeFourthPeraLogoItemPath(&peraLogoPath)
        composeFifthPeraLogoItemPath(&peraLogoPath)
        composeSixthPeraLogoItemPath(&peraLogoPath)

        peraLogoPath.flatness = 0.01
        return peraLogoPath
    }

    private func composeFirstPeraLogoItemPath(
        _ path: inout UIBezierPath
    ) {
        path.move(to: (48.5, 14.1))
        path.addCurve((47, 30.8), from: (50.6, 22.6), to: (49.9, 30))
        path.addCurve((38, 16.7), from: (44.1, 31.5), to: (40.1, 25.2))
        path.addCurve((39.6, 0.1), from: (36, 8.2), to: (36.7, 0.8))
        path.addCurve((48.5, 14.1), from: (42.5, -0.7), to: (46.5, 5.6))
        path.close()
    }

    private func composeSecondPeraLogoItemPath(
        _ path: inout UIBezierPath
    ) {
        path.move(to: (82.4, 21.4))
        path.addCurve((62.2, 24.3), from: (77.8, 16.6), to: (68.8, 17.9))
        path.addCurve((58.5, 44.6), from: (55.6, 30.7), to: (53.9, 39.8))
        path.addCurve((78.6, 41.7), from: (63, 49.4), to: (72, 48.1))
        path.addCurve((82.4, 21.4), from: (85.2, 35.3), to: (86.9, 26.2))
        path.close()
    }

    private func composeThirdPeraLogoItemPath(
        _ path: inout UIBezierPath
    ) {
        path.move(to: (46.3, 95))
        path.addCurve((47.6, 77.4), from: (49.2, 94.3), to: (49.8, 86.4))
        path.addCurve((38.4, 62.4), from: (45.4, 68.4), to: (41.3, 61.7))
        path.addCurve((37.1, 80), from: (35.5, 63.1), to: (34.9, 71))
        path.addCurve((46.3, 95), from: (39.3, 89), to: (43.4, 95.7))
        path.close()
    }

    private func composeFourthPeraLogoItemPath(
        _ path: inout UIBezierPath
    ) {
        path.move(to: (16.7, 25.8))
        path.addCurve((30.4, 35.5), from: (25.1, 28.3), to: (31.2, 32.6))
        path.addCurve((13.7, 36.2), from: (29.6, 38.3), to: (22.1, 38.7))
        path.addCurve((0.1, 26.5), from: (5.4, 33.7), to: (-0.8, 29.4))
        path.addCurve((16.7, 25.8), from: (0.9, 23.7), to: (8.4, 23.3))
        path.close()
    }

    private func composeFifthPeraLogoItemPath(
        _ path: inout UIBezierPath
    ) {
        path.move(to: (71, 58.2))
        path.addCurve((85.6, 68.2), from: (79.9, 60.9), to: (86.5, 65.3))
        path.addCurve((68.1, 68.6), from: (84.8, 71.1), to: (76.9, 71.3))
        path.addCurve((53.5, 58.7), from: (59.2, 66), to: (52.6, 61.6))
        path.addCurve((71, 58.2), from: (54.3, 55.8), to: (62.2, 55.6))
        path.close()
    }

    private func composeSixthPeraLogoItemPath(
        _ path: inout UIBezierPath
    ) {
        path.move(to: (26.1, 52.2))
        path.addCurve((10.9, 59.2), from: (24.1, 50.1), to: (17.3, 53.2))
        path.addCurve((3.2, 74), from: (4.6, 65.2), to: (1.2, 71.8))
        path.addCurve((18.5, 67), from: (5.3, 76.1), to: (12.1, 73))
        path.addCurve((26.1, 52.2), from: (24.8, 61), to: (28.2, 54.4))
        path.close()
    }

    private func composeCardBox(from path: UIBezierPath) -> SCNShape {
        let cardBox = SCNShape(path: path, extrusionDepth: 0.2)
        cardBox.chamferRadius = 0.05

        let boxMaterial = composeBoxMaterial()

        if let sceneMaterial = sceneMaterial {
            cardBox.materials = [
                sceneMaterial,
                boxMaterial,
                boxMaterial,
                boxMaterial,
                boxMaterial,
                boxMaterial
            ]
        } else {
            cardBox.materials = [
                boxMaterial,
                boxMaterial,
                boxMaterial,
                boxMaterial,
                boxMaterial
            ]
        }

        return cardBox
    }

    private func composeBoxMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(
            red: 0.1,
            green: 0.1,
            blue: 0.1,
            alpha: 1.0
        )
        material.metalness.contents = UIColor.darkGray
        material.lightingModel = .physicallyBased
        return material
    }

    private func composeLogoMaterial() -> SCNMaterial {
        let logoMaterial = SCNMaterial()
        logoMaterial.diffuse.contents = UIColor(
            red: 0.6,
            green: 0.6,
            blue: 0.6,
            alpha: 1.0
        )
        logoMaterial.metalness.contents = UIColor.white
        logoMaterial.lightingModel = .physicallyBased
        logoMaterial.shininess = 0.8
        return logoMaterial
    }

    private func composePeraLogoNode(from shape: SCNShape) -> SCNNode {
        let peraLogoNode = SCNNode(geometry: shape)
        peraLogoNode.scale = SCNVector3(0.01, 0.01, 0.01)
        peraLogoNode.position = SCNVector3(0, 0, -0.1)
        peraLogoNode.pivot = SCNMatrix4MakeTranslation(45.0, 50.0, 0.0)
        peraLogoNode.rotation = SCNVector4Make(0, 0, 1, Float(Double.pi))
        return peraLogoNode
    }

    private func composeGroupNode(
        from cardNode: SCNNode,
        and peraLogoNode: SCNNode
    ) -> SCNNode {
        let groupNode = SCNNode()
        groupNode.name = Collectible3DCardDisplayableConstants.groupNode.rawValue
        groupNode.addChildNode(cardNode)
        groupNode.addChildNode(peraLogoNode)
        groupNode.pivot = SCNMatrix4MakeRotation(0, 0, 1, 0)
        return groupNode
    }

    private func getSpinAnimation() -> CABasicAnimation {
        let spinAnimation = CABasicAnimation(keyPath: "rotation")
        spinAnimation.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float(Double.pi)))
        spinAnimation.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: 0))
        spinAnimation.duration = 0.8
        spinAnimation.repeatCount = 1
        spinAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        return spinAnimation
    }

    private func addSceneToCameraNode(_ scene: SCNScene) {
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 10)
        scene.rootNode.addChildNode(cameraNode)
    }
}

enum Collectible3DCardDisplayableConstants: String {
    case groupNode
}
