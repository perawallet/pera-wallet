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
    
    lazy var testNetAlgodHost = "node-testnet.chain.perawallet.app"
    lazy var testNetIndexerHost = "indexer-testnet.chain.perawallet.app"
    lazy var testNetAlgodApi = "\(schema)://\(testNetAlgodHost)/v2"
    lazy var testNetIndexerApi = "\(schema)://\(testNetIndexerHost)/v2"
    
    lazy var mainNetAlgodHost = "node-mainnet.chain.perawallet.app"
    lazy var mainNetIndexerHost = "indexer-mainnet.chain.perawallet.app"
    lazy var mainNetAlgodApi = "\(schema)://\(mainNetAlgodHost)/v2"
    lazy var mainNetIndexerApi = "\(schema)://\(mainNetIndexerHost)/v2"
    
    lazy var serverHost: String = {
        switch target {
        case .staging:
            return testNetAlgodHost
        case .prod:
            return mainNetAlgodHost
        }
    }()
    
    lazy var mobileHost = "api.perawallet.app"

    lazy var algoExplorerApiHost = "price.algoexplorerapi.io"
    
    lazy var serverApi: String = {
        let api = "\(schema)://\(serverHost)"
        return api
    }()
    
    lazy var mobileApi: String = {
        switch target {
        case .staging:
            return "https://staging.\(mobileHost)/v1/"
        case .prod:
            return "https://\(mobileHost)/v1/"
        }
    }()

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
    case algorand = "https://www.algorand.com"
    case peraWebApp = "https://wallet.perawallet.app"
    case termsAndServices = "https://www.perawallet.app/terms-and-services/"
    case privacyPolicy = "https://www.perawallet.app/privacy-policy/"
    case support = "https://perawallet.app/support/"
    case dispenser = "https://dispenser.testnet.aws.algodev.network/"
    case backUpSupport = "https://perawallet.app/support/passphrase/"
    case recoverSupport = "https://perawallet.app/support/recover-account/"
    case watchAccountSupport = "https://perawallet.app/support/watch-accounts/"
    case ledgerSupport = "https://perawallet.app/support/ledger/"
    case transactionSupport = "https://perawallet.app/support/transactions/"
    case rewardsFAQ = "https://algorand.foundation/faq#participation-rewards"
    case governence = "https://governance.algorand.foundation/"
    case peraBlogLaunchAnnouncement = "https://perawallet.app/blog/launch-announcement/"
    case asaVerificationSupport = "https://explorer.perawallet.app/asa-verification/"
    case tinymanTermsOfService = "https://tinyman.org/terms-of-service"
    case tinymanSwapMain = "https://app.tinyman.org/#/swap?asset_in=0"
    case tinymanSwap = "http://perawallet.app/support/swap/"

    var presentation: String {
        switch self {
        case .peraWebApp:
            return "wallet.perawallet.app"
        case .support:
            return "www.perawallet.app/support/"
        default:
            return self.rawValue
        }
    }
    
    enum AlgoExplorer {
        case address(isMainnet: Bool, param: String)
        case asset(isMainnet: Bool, param: String)
        case group(isMainnet: Bool, param: String)
        
        var link: URL? {
            switch self {
            case .address(let isMainnet, let param):
                return isMainnet
                    ? URL(string: "https://algoexplorer.io/address/\(param)")
                    : URL(string: "https://testnet.algoexplorer.io/address/\(param)")
            case .asset(let isMainnet, let param):
                return isMainnet
                    ? URL(string: "https://algoexplorer.io/asset/\(param)")
                    : URL(string: "https://testnet.algoexplorer.io/asset/\(param)")
            case .group(let isMainnet, let param):
                return isMainnet
                    ? URL(string: "https://algoexplorer.io/tx/group/\(param)")
                    : URL(string: "https://testnet.algoexplorer.io/tx/group/\(param)")
            }
        }
    }
    
    enum NftExplorer {
        case asset(isMainnet: Bool, param: String)
        
        var link: URL? {
            switch self {
            case .asset(let isMainnet, let param):
                return isMainnet
                    ? URL(string: "https://www.nftexplorer.app/asset/\(param)")
                    : nil
            }
        }
    }
}

extension AlgorandWeb {
    var link: URL? {
        return URL(string: rawValue)
    }
}
