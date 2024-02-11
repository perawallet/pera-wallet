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

//   ALGAnalyticsEvent.swift

import Foundation
import MacaroonVendors
import UIKit

protocol ALGAnalyticsEvent:
    AnalyticsEvent,
    ALGAnalyticsParameterRegulator
where
    Self.Name == ALGAnalyticsEventName,
    Self.Metadata == ALGAnalyticsMetadata {}

/// <note>
/// Naming convention:
/// Action-related name should be used, i.e. either showQRCopy (active) or wcSessionApproved (passive)
/// Some providers may not support a name that is too long. For example, in Firebase Analytics, the maximum supported length is 40 characters. Therefore, event names should be adjusted accordingly.
/// Sort:
/// Alphabetical order
enum ALGAnalyticsEventName:
    String,
    AnalyticsEventName {
    case addAsset
    case buyAlgoFromMoonPayCompleted
    case changeAssetDetail
    case changeCurrency
    case changeLanguage
    case changeNotificationFilter
    case completeTransaction
    case createAccountInHomeScreen
    case discoverSearch
    case discoverAssetBuy
    case discoverAssetSell
    case discoverDappDetail
    case manageAsset
    case onboardCreateAccountNew
    case onboardCreateAccountSkip
    case onboardCreateAccountWatch
    case onboardCreateAccountBeginPassphrase
    case onboardCreateAccountCopyPassphrase
    case onboardCreateAccountUnderstandPassphrase
    case onboardCreateAccountVerifyPassphrase
    case onboardCreateAccountVerifiedBuyAlgo
    case onboardCreateAccountVerifiedStart
    case onboardVerifiedSetPinCode
    case onboardVerifiedSetPinCodeCompleted
    case onboardWatchAccountCreate
    case onboardWatchAccountCreateCompleted
    case onboardWelcomeScreenAccountCreate
    case onboardWelcomeScreenAccountRecover
    case qrConnectedInHome
    case registerAccount
    case rekeyAccount
    case showAssetDetail
    case showQRCopy
    case showQRShare
    case showQRShareComplete
    case swapAssetFailed
    case swapBannerLater
    case swapBannerTry
    case swapCompleted
    case swapFailed
    case tapAssetsInAccountDetail
    case tapAlgoPriceMenu
    case tapBuyAlgoInAccountDetail
    case tapBuyAlgoInBottomsheet
    case tapBuyAlgoInHome
    case tapBuyAlgoInMoonPay
    case tapBuyAlgoInMeld
    case tapBuyAlgoTab
    case tapCollectiblesInAccountDetail
    case tapConfirmSwap
    case tapDownloadTransactionInHistory
    case tapFilterTransactionInHistory
    case tapGovernanceBanner
    case tapHistoryInAccountDetail
    case tapNftReceive
    case tapReceiveInDetail
    case tapReceiveTab
    case tapSendInDetail
    case tapSendTab
    case tapSwapInAccountDetail
    case tapSwapInAlgoDetail
    case tapSwapInHome
    case tapSwapInSwapScreen
    case tapSwapInQuickAction
    case tapQRInHome
    case wcSessionApproved
    case wcSessionDisconnected
    case wcSessionRejected
    case wcTransactionConfirmed
    case wcTransactionDeclined
    case wcTransactionRequestDidAppear
    case wcTransactionRequestDidLoad
    case wcTransactionRequestReceived
    case wcTransactionRequestSDKError
    case wcTransactionRequestValidated
}

extension ALGAnalyticsEventName {
    var rawValue: String {
        /// Sort:
        /// Alphabetical order by `rawName`.
        let rawName: String
        switch self {
        case .tapAssetsInAccountDetail: rawName = "accountscr_assets_tap"
        case .tapCollectiblesInAccountDetail: rawName = "accountscr_collectibles_tap"
        case .tapHistoryInAccountDetail: rawName = "accountscr_history_tap"
        case .tapBuyAlgoInAccountDetail: rawName = "accountscr_tapmenu_algo_buy_tap"
        case .tapSwapInAccountDetail: rawName = "accountscr_swap_click"
        case .tapSwapInAlgoDetail : rawName = "algoasadetail_swap_click"
        case .showAssetDetail: rawName = "asset_detail_asset"
        case .changeAssetDetail: rawName = "asset_detail_asset_change"
        case .addAsset: rawName = "assetscr_asset_add"
        case .manageAsset: rawName = "assetscr_assets_manage"
        case .swapBannerLater: rawName = "banner_swap_later"
        case .swapBannerTry: rawName = "banner_swap_tryswap"
        case .tapBuyAlgoInBottomsheet: rawName = "bottommenu_algo_buy_tap"
        case .changeCurrency: rawName = "currency_change"
        case .discoverDappDetail: rawName = "discover_dapps_visit_pages"
        case .discoverSearch: rawName = "discover_markets_search"
        case .discoverAssetBuy: rawName = "discover_token_detail_buy"
        case .discoverAssetSell: rawName = "discover_token_detail_sell"
        case .tapGovernanceBanner: rawName = "homescr_visitgovernance"
        case .tapDownloadTransactionInHistory: rawName = "historyscr_transactions_download"
        case .tapFilterTransactionInHistory: rawName = "historyscr_transactions_filter"
        case .createAccountInHomeScreen: rawName = "homescr_account_add"
        case .tapBuyAlgoInHome: rawName = "homescr_algo_buy_tap"
        case .tapSwapInHome: rawName = "homescr_swap_click"
        case .tapQRInHome: rawName = "homescr_qr_scan"
        case .qrConnectedInHome: rawName = "homescr_qr_scan_connected"
        case .changeLanguage: rawName = "language_change"
        case .tapAlgoPriceMenu: rawName = "nftscr_nft_receive"
        case .tapBuyAlgoInMeld: rawName = "meldscr_algo_buy_tap"
        case .tapBuyAlgoInMoonPay: rawName = "moonpayscr_algo_buy_tap"
        case .buyAlgoFromMoonPayCompleted: rawName = "moonpaycom_algo_buy_completed"
        case .tapNftReceive: rawName = "nftscr_nft_receive"
        case .changeNotificationFilter: rawName = "notification_filter_change"
        case .onboardCreateAccountNew: rawName = "onb_createacc_recover"
        case .onboardCreateAccountBeginPassphrase: rawName = "onb_createacc_pass_begin"
        case .onboardCreateAccountCopyPassphrase: rawName = "onb_createacc_pass_copy"
        case .onboardCreateAccountUnderstandPassphrase: rawName = "onb_createacc_pass_understand"
        case .onboardCreateAccountVerifyPassphrase: rawName = "onb_createacc_pass_verify"
        case .onboardCreateAccountVerifiedBuyAlgo: rawName = "onb_createacc_verified_buyalgo"
        case .onboardCreateAccountVerifiedStart: rawName = "onb_createacc_verified_start"
        case .onboardCreateAccountSkip: rawName = "onb_createacc_skip"
        case .onboardCreateAccountWatch: rawName = "onb_createacc_watch"
        case .onboardVerifiedSetPinCode: rawName = "onb_verified_setpincode"
        case .onboardVerifiedSetPinCodeCompleted: rawName = "onb_verified_setpincode_completed"
        case .onboardWatchAccountCreate: rawName = "onb_watchacc_create"
        case .onboardWatchAccountCreateCompleted: rawName = "onb_watchacc_create_verified"
        case .onboardWelcomeScreenAccountCreate: rawName = "onb_welcome_account_create"
        case .onboardWelcomeScreenAccountRecover: rawName = "onb_welcome_account_recover"
        case .registerAccount: rawName = "register"
        case .rekeyAccount: rawName = "rekey"
        case .swapCompleted: rawName = "swapscr_assets_completed"
        case .swapFailed: rawName = "swapscr_assets_failed"
        case .tapConfirmSwap: rawName = "swapscr_assets_confirm"
        case .swapAssetFailed: rawName = "swapscr_assets_failed"
        case .tapSwapInSwapScreen: rawName = "swapscr_assets_swap"
        case .tapReceiveInDetail: rawName = "tap_asset_detail_receive"
        case .tapSendInDetail: rawName = "tap_asset_detail_send"
        case .showQRCopy: rawName = "tap_show_qr_copy"
        case .showQRShare: rawName = "tap_show_qr_share"
        case .showQRShareComplete: rawName = "tap_show_qr_share_complete"
        case .tapBuyAlgoTab: rawName = "tap_tab_buy_algo"
        case .tapReceiveTab: rawName = "tap_tab_receive"
        case .tapSendTab: rawName = "tap_tab_send"
        case .completeTransaction: rawName = "transaction"
        case .tapSwapInQuickAction: rawName = "quickaction_swap_click"
        case .wcSessionApproved: rawName = "wc_session_approved"
        case .wcSessionDisconnected: rawName = "wc_session_disconnected"
        case .wcSessionRejected: rawName = "wc_session_rejected"
        case .wcTransactionConfirmed: rawName = "wc_transaction_confirmed"
        case .wcTransactionDeclined: rawName = "wc_transaction_declined"
        case .wcTransactionRequestDidAppear: rawName = "wc_transaction_request_DidAppear"
        case .wcTransactionRequestDidLoad: rawName = "wc_transaction_request_DidLoad"
        case .wcTransactionRequestReceived: rawName = "wc_transaction_request_Received"
        case .wcTransactionRequestSDKError: rawName = "wc_transaction_request_SDKError"
        case .wcTransactionRequestValidated: rawName = "wc_transaction_request_Validated"
        }

        let isTestnet = UIApplication.shared.appConfiguration?.api.isTestNet ?? false
        return isTestnet ? "t_\(rawName)" : rawName
    }
}
