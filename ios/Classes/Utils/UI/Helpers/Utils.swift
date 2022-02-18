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
//  Utils.swift

import UIKit

func img(_ named: String) -> UIImage? {
    return img(named, isTemplate: false)
}

func color(_ named: String) -> UIColor {
    return UIColor(named: named) ?? .black
}

func img(_ named: String, isTemplate: Bool) -> UIImage? {
    let image: UIImage?
    
    if isTemplate {
        image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
    } else {
        image = UIImage(named: named)
    }
    
    return image
}

func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
    return UIColor(red: red, green: green, blue: blue, alpha: 1)
}

func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return UIColor(red: red, green: green, blue: blue, alpha: min(1.0, max(0.0, alpha)))
}

let verticalScale = UIScreen.main.bounds.height / 812.0 > 1.0 ? 1.0 : UIScreen.main.bounds.height / 812.0
let horizontalScale = UIScreen.main.bounds.width / 375.0 > 1.0 ? 1.0 : UIScreen.main.bounds.width / 375.0 

func runIfDebug(_ closure: () -> Void) {
    #if DEBUG
    closure()
    #endif
}

func runIfRelease(_ closure: () -> Void) {
    #if !DEBUG
    closure()
    #endif
}
