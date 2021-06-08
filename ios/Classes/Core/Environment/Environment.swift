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
//  Environment.swift

import Foundation

private enum AppTarget {
    case staging, prod
}

class Environment {
    
    private static let instance = Environment()
    
    static var current: Environment {
        return instance
    }
    
    let appID = "1459898525"
    
    lazy var isTestNet = target == .staging
    
    lazy var schema = "https"
    
    lazy var algodToken: String = {
        guard let token = Bundle.main.infoDictionary?["ALGOD_TOKEN"] as? String else {
            return ""
        }
        return token
    }()

    lazy var indexerToken: String = {
        guard let token = Bundle.main.infoDictionary?["INDEXER_TOKEN"] as? String else {
            return ""
        }
        return token
    }()
    
    lazy var testNetAlgodHost = "node-testnet.aws.algodev.network"
    lazy var testNetIndexerHost = "indexer-testnet.aws.algodev.network"
    lazy var testNetAlgodApi = "\(schema)://\(testNetAlgodHost)"
    lazy var testNetIndexerApi = "\(schema)://\(testNetIndexerHost)"
    
    lazy var mainNetAlgodHost = "node-mainnet.aws.algodev.network"
    lazy var mainNetIndexerHost = "indexer-mainnet.aws.algodev.network"
    lazy var mainNetAlgodApi = "\(schema)://\(mainNetAlgodHost)"
    lazy var mainNetIndexerApi = "\(schema)://\(mainNetIndexerHost)"
    
    lazy var serverHost: String = {
        switch target {
        case .staging:
            return testNetAlgodHost
        case .prod:
            return mainNetAlgodHost
        }
    }()
    
    lazy var mobileHost = "mobile-api.algorand.com"

    lazy var algoExplorerApiHost = "price.algoexplorerapi.io"
    
    lazy var serverApi: String = {
        let api = "\(schema)://\(serverHost)"
        return api
    }()
    
    lazy var mobileApi: String = {
        switch target {
        case .staging:
            return "https://staging.\(mobileHost)"
        case .prod:
            return "https://\(mobileHost)"
        }
    }()
    
    lazy var testNetMobileApi = "https://staging.\(mobileHost)"
    
    lazy var mainNetMobileApi = "https://\(mobileHost)"

    lazy var algoExplorerApi = "https://\(algoExplorerApiHost)"
    
    private let target: AppTarget
    
    private init() {
        #if PRODUCTION
        target = .prod
        #else
        target = .staging
        #endif
    }
}

enum AlgorandWeb: String {
    case termsAndServices = "https://www.algorand.com/wallet-disclaimer"
    case privacyPolicy = "https://www.algorand.com/wallet-privacy-policy"
    case support = "https://algorandwallet.com/support"
    case dispenser = "https://bank.testnet.algorand.network"
    case backUpSupport = "https://algorandwallet.com/support/security/backing-up-your-recovery-passphrase"
    case recoverSupport = "https://algorandwallet.com/support/getting-started/recover-an-algorand-account"
    case watchAccountSupport = "https://algorandwallet.com/support/general/adding-a-watch-account"
    case ledgerSupport = "https://algorandwallet.com/support/security/pairing-your-ledger-nano-x"
    case transactionSupport = "https://algorandwallet.com/support/transacting"
    case rewardsFAQ = "https://algorand.foundation/faq#participation-rewards"
}

extension AlgorandWeb {
    var link: URL? {
        return URL(string: rawValue)
    }
}
