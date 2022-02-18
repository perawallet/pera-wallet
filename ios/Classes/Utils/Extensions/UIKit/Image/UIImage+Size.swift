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
//  UIImage+Size.swift

import UIKit

extension UIImage {
    
    func convert(to targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        var editedSize: CGSize
        
        if widthRatio > heightRatio {
            editedSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            editedSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: editedSize.width, height: editedSize.height)
        
        UIGraphicsBeginImageContextWithOptions(editedSize, false, 0.0)
        draw(in: rect)
        
        let editedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return editedImage
    }
}
