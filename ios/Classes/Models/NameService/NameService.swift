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

//   NameService.swift

import Foundation

final class NameServiceList:
    PaginatedList<NameService>,
    ALGEntityModel {
    convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrap(or: [])
        )
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.count = count
        apiModel.next = next
        apiModel.previous = previous
        apiModel.results = results
        return apiModel
    }
}

extension NameServiceList {
    struct APIModel:
        ALGAPIModel,
        PaginationComponents {
        var count: Int?
        var next: URL?
        var previous: String?
        var results: [NameService]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}

final class NameService:
    ALGAPIModel,
    Hashable {
    let name: String
    let address: String
    let service: Service

    var account: AccountHandle {
        let localAccount = AccountInformation(
            address: address,
            name: name,
            isWatchAccount: false,
            isBackedUp: true
        )
        let aRawAccount = Account(localAccount: localAccount)
        return AccountHandle(
            account: aRawAccount,
            status: .idle
        )
    }

    init() {
        name = ""
        address = ""
        service = Service()
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case address
        case service
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }

    static func == (
        lhs: NameService,
        rhs: NameService
    ) -> Bool {
        return lhs.address == rhs.address
    }
}

final class Service: ALGAPIModel {
    let name: String
    let logo: String

    init() {
        name = ""
        logo = ""
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case logo
    }
}
