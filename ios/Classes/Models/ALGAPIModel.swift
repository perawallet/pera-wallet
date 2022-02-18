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
//   ALGAPIModel.swift

import Foundation
import MacaroonUtils
import MagpieCore

protocol ALGAPIModel: APIModel {
    init()
}

extension ALGAPIModel {
    public static var encodingStrategy: JSONEncodingStrategy {
        return JSONEncodingStrategy(
            keys: .useDefaultKeys,
            date: .formatted(Date.toFormatter(.fullNumeric)),
            data: .base64
        )
    }
    public static var decodingStrategy: JSONDecodingStrategy {
        return JSONDecodingStrategy(
            keys: .useDefaultKeys,
            date: .formatted(Date.toFormatter(.fullNumeric)),
            data: .base64
        )
    }
}

extension String: ALGAPIModel {}
