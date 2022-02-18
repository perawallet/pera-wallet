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

//
//  Shadow.swift

import UIKit

struct Shadow {
    let color: UIColor
    let offset: CGSize
    let radius: CGFloat
    let opacity: Float
}

let smallTopShadow = Shadow(color: Colors.Shadow.smallTop, offset: CGSize(width: 0.0, height: 4.0), radius: 6.0, opacity: 1.0)
let smallBottomShadow = Shadow(color: Colors.Shadow.smallBottom, offset: CGSize(width: 0.0, height: 1.0), radius: 3.0, opacity: 1.0)
let mediumTopShadow = Shadow(color: Colors.Shadow.mediumTop, offset: CGSize(width: 0.0, height: 4.0), radius: 12.0, opacity: 1.0)
let mediumBottomShadow = Shadow(color: Colors.Shadow.mediumBottom, offset: CGSize(width: 0.0, height: 2.0), radius: 6.0, opacity: 1.0)
let errorShadow = Shadow(color: Colors.Shadow.error, offset: CGSize(width: 0.0, height: 8.0), radius: 20.0, opacity: 1.0)
