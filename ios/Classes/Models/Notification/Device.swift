// Copyright 2019 Algorand, Inc.

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
//  Device.swift

import Magpie

class Device: Model {
    let id: String?
    let pushToken: String?
    let platform: String?
    let model: String?
    let locale: String?
}

extension Device {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case pushToken = "push_token"
        case platform = "platform"
        case model = "model"
        case locale = "locale"
    }
}
