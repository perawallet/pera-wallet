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
//  API+Account.swift

import Foundation
import MagpieCore
import MagpieHipo
import MagpieExceptions

extension ALGAPI {
    @discardableResult
    func fetchAccount(
        _ draft: AccountFetchDraft,
        includesClosedAccounts: Bool = false,
        queue: DispatchQueue,
        ignoreResponseOnCancelled: Bool,
        onCompleted handler: @escaping (Response.ModelResult<AccountResponse>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.indexer(network))
            .path(.accountDetail, args: draft.publicKey)
            .query(AccountQuery(includesAll: includesClosedAccounts))
            .method(.get)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .responseDispatcher(queue)
            .execute()
    }

    @discardableResult
    func fetchRekeyedAccounts(
        _ account: String,
        onCompleted handler: @escaping (Response.ModelResult<RekeyedAccountsResponse>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.indexer(network))
            .path(.accounts)
            .method(.get)
            .query(RekeyedAccountQuery(authAddress: account))
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func exportAccounts(
        _ draft: EncryptedExportAccountDraft,
        onCompleted handler: @escaping (Response.Result<NoAPIModel, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        let modificationHeader: Headers

        if let modificationKey = draft.qrBackupParameters.modificationKey {
            modificationHeader = [ModificationHeader(modificationKey)]
        } else {
            modificationHeader = []
        }

        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.backups, args: draft.qrBackupParameters.id)
            .method(.put)
            .headers(modificationHeader)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func fetchBackupDetail(
        _ backupID: String,
        onCompleted handler: @escaping (Response.Result<Backup, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.backups, args: backupID)
            .method(.get)
            .completionHandler(handler)
            .execute()
    }
}
