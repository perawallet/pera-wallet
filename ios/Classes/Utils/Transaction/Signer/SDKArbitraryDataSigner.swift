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

//   SDKArbitraryDataSigner.swift

import Foundation

final class SDKArbitraryDataSigner: TransactionSigner {
    override func sign(
        _ data: Data?,
        with privateData: Data?
    ) -> Data? {
        var error: NSError?

        guard let unsignedArbitraryData = data,
              let privateData,
              let signedArbitraryData = algorandSDK.signBytes(
                data: unsignedArbitraryData,
                with: privateData,
                with: &error
              ) else {
            delegate?.transactionSigner(
                self,
                didFailedSigning: .inapp(TransactionError.sdkError(error: error))
            )
            return nil
        }

        return signedArbitraryData
    }
}
