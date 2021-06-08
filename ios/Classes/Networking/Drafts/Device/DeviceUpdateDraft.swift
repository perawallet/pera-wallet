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
//  DeviceUpdateDraft.swift

import Magpie

struct DeviceUpdateDraft: JSONObjectBody {
    let id: String
    let pushToken: String?
    let platform = "ios"
    let model = UIDevice.current.model
    let locale = Locale.current.languageCode ?? "en"
    var accounts: [String] = []
    
    var bodyParams: [BodyParam] {
        var params: [BodyParam] = []
        params.append(.init(.id, id))
        params.append(.init(.platform, platform))
        params.append(.init(.model, model))
        params.append(.init(.locale, locale))
        params.append(.init(.accounts, accounts))
        params.append(.init(.pushToken, pushToken, .setIfPresent))
        return params
    }
}
