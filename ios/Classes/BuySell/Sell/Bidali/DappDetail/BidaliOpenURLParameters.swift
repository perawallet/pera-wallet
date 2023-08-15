// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   BidaliOpenURLParameters.swift

import Foundation
import MacaroonUtils

struct BidaliOpenURLParameters: JSONModel {
    let data: BidaliOpenURLRequest?
}

struct BidaliOpenURLRequest: JSONModel {
    /// URL to support docs, etc. Ideally should open in an external browser or a new in-app modal browser.
    let url: String?
}
