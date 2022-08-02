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

//   TooltipView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class TooltipView:
    View,
    ViewModelBindable {
    private lazy var titleView = Label()

    private let theme: TooltipViewTheme
    private let arrowLocationX: CGFloat

    private var isLayoutFinalized = false

    init(
        arrowLocationX: CGFloat,
        theme: TooltipViewTheme = .init()
    ) {
        self.arrowLocationX = arrowLocationX
        self.theme = theme
        super.init(frame: .zero)

        customize(theme)
    }

    private func customize(
        _ theme: TooltipViewTheme
    ) {
        addTitle(theme)
    }

    func bindData(
        _ viewModel: TooltipViewModel?
    ) {
        titleView.editText = viewModel?.title
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty {
            return
        }

        if !isLayoutFinalized {
            isLayoutFinalized = true

            addContent()
        }
    }
}

extension TooltipView {
    private func addContent() {
        let arrowWidth: CGFloat = theme.arrowSize.w
        let arrowHeight: CGFloat = theme.arrowSize.h

        let arrowXOffset: CGFloat =
        arrowLocationX
        - frame.minX
        - arrowWidth

        let cornerRadius: CGFloat = theme.corner.radius

        let mainRect = CGRect(
            origin: bounds.origin,
            size: CGSize(
                width: bounds.width,
                height: bounds.height - arrowHeight
            )
        )

        let leftTopPoint = mainRect.origin
        let rightTopPoint = CGPoint(
            x: mainRect.maxX,
            y: mainRect.minY
        )

        let rightBottomPoint = CGPoint(
            x: mainRect.maxX,
            y: mainRect.maxY
        )
        let leftBottomPoint = CGPoint(
            x: mainRect.minX,
            y: mainRect.maxY
        )

        let leftArrowPoint = CGPoint(
            x: leftBottomPoint.x + arrowXOffset,
            y: leftBottomPoint.y
        )
        let centerArrowPoint = CGPoint(
            x: leftArrowPoint.x + arrowWidth / 2,
            y: leftArrowPoint.y + arrowHeight
        )
        let rightArrowPoint = CGPoint(
            x: leftArrowPoint.x + arrowWidth,
            y: leftArrowPoint.y
        )

        let path = UIBezierPath()
        path.addArc(
            withCenter: CGPoint(
                x: rightTopPoint.x - cornerRadius,
                y: rightTopPoint.y + cornerRadius
            ),
            radius: cornerRadius,
            startAngle: 3 * CGFloat.pi / 2,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        )
        path.addArc(
            withCenter: CGPoint(
                x: rightBottomPoint.x - cornerRadius,
                y: rightBottomPoint.y - cornerRadius
            ),
            radius: cornerRadius,
            startAngle: 0,
            endAngle: CGFloat.pi / 2,
            clockwise: true
        )

        path.addLine(to: rightArrowPoint)
        path.addLine(to: centerArrowPoint)
        path.addLine(to: leftArrowPoint)

        path.addArc(
            withCenter: CGPoint(
                x: leftBottomPoint.x + cornerRadius,
                y: leftBottomPoint.y - cornerRadius
            ),
            radius: cornerRadius,
            startAngle: CGFloat.pi / 2,
            endAngle: CGFloat.pi,
            clockwise: true
        )
        path.addArc(
            withCenter: CGPoint(
                x: leftTopPoint.x + cornerRadius,
                y: leftTopPoint.y + cornerRadius
            ),
            radius: cornerRadius,
            startAngle: CGFloat.pi,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )

        path.addLine(to: rightTopPoint)
        path.close()

        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.fillColor = theme.backgroundColor.uiColor.cgColor
        layer.insertSublayer(shape, at: 0)
    }
}

extension TooltipView {
    private func addTitle(
        _ theme: TooltipViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.contentEdgeInsets = theme.titleContentEdgeInsets
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == theme.arrowSize.h
            $0.trailing == 0
        }
    }
}
