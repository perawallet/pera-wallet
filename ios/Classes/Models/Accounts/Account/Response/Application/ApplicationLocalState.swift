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
//   ApplicationLocalState.swift

import Magpie

class ApplicationLocalState: Model {
    var closedAtRound: Int64?
    var isDeleted: Bool?
    var id: Int64?
    var optedInAtRound: Int64?
    var schema: ApplicationStateSchema?
}

extension ApplicationLocalState {
    enum CodingKeys: String, CodingKey {
        case closedAtRound = "closed-out-at-round"
        case isDeleted = "deleted"
        case id = "id"
        case optedInAtRound = "opted-in-at-round"
        case schema = "schema"
    }
}
