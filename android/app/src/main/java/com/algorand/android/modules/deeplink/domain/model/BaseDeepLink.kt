@file:Suppress("MaxLineLength", "MagicNumber")

/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.modules.deeplink.domain.model

import com.algorand.android.models.AssetInformation
import com.algorand.android.modules.swap.assetswap.data.utils.getSafeAssetIdForResponse
import com.algorand.android.modules.webimport.common.data.model.WebImportQrCode
import com.algorand.android.utils.isEqualTo
import java.math.BigInteger
import kotlin.reflect.full.companionObjectInstance

/**
 * Model classes for supported DeepLinks & AppLinks
 * Can be tested by executing the command below;
 * adb shell am start -a android.intent.action.VIEW -d "DEEPLINK" com.algorand.android
 */
sealed class BaseDeepLink {

    interface DeepLinkCreator {
        fun createDeepLink(rawDeeplink: RawDeepLink): BaseDeepLink
        fun doesDeeplinkMeetTheRequirements(rawDeepLink: RawDeepLink): Boolean
    }

    companion object {

        protected const val DEFAULT_ACCOUNT_ADDRESS = ""
        protected const val DEFAULT_WALLET_CONNECT_URL = ""
        protected const val DEFAULT_AMOUNT = 0L
        protected const val DEFAULT_MNEMONIC = ""
        protected const val DEFAULT_TRANSACTION_STATUS = ""
        protected const val DEFAULT_WEBIMPORT_BACKUPID = ""
        protected const val DEFAULT_WEBIMPORT_ENCRYPTIONKEY = ""
        protected val DEFAULT_NOTIFICATION_GROUP_TYPE = NotificationGroupType.TRANSACTIONS

        fun create(rawDeepLink: RawDeepLink): BaseDeepLink {
            return BaseDeepLink::class.sealedSubclasses.firstNotNullOfOrNull {
                (it.companionObjectInstance as? DeepLinkCreator)?.run {
                    if (doesDeeplinkMeetTheRequirements(rawDeepLink)) {
                        createDeepLink(rawDeepLink)
                    } else null
                }
            } ?: UndefinedDeepLink.create(rawDeepLink)
        }
    }

    /**
     * Examples;
     *  - perawallet://WOLFYW4VEVVGEGVLQWEL4EMJ5SFCD3UCNKDH2DCUB5HQ6HLM6URZBMPXLI
     *  - algorand://WOLFYW4VEVVGEGVLQWEL4EMJ5SFCD3UCNKDH2DCUB5HQ6HLM6URZBMPXLI
     */
    class AccountAddressDeepLink private constructor(
        val accountAddress: String,
        val label: String?
    ) : BaseDeepLink() {

        override fun equals(other: Any?): Boolean {
            return other is AccountAddressDeepLink && other.accountAddress == accountAddress
        }

        override fun hashCode(): Int {
            return accountAddress.hashCode()
        }

        companion object : DeepLinkCreator {

            override fun createDeepLink(rawDeeplink: RawDeepLink): BaseDeepLink {
                return AccountAddressDeepLink(
                    accountAddress = rawDeeplink.accountAddress ?: DEFAULT_ACCOUNT_ADDRESS,
                    label = rawDeeplink.label
                )
            }

            override fun doesDeeplinkMeetTheRequirements(rawDeepLink: RawDeepLink): Boolean {
                return with(rawDeepLink) {
                    accountAddress != null &&
                        walletConnectUrl == null &&
                        assetId == null &&
                        amount == null &&
                        note == null &&
                        xnote == null &&
                        webImportQrCode == null &&
                        notificationGroupType == null
                }
            }
        }
    }

    /**
     * Examples;
     *  - algorand://?amount=0&asset=776191503
     *  - perawallet://?amount=0&asset=77619150
     */
    class AssetOptInDeepLink private constructor(
        val assetId: Long
    ) : BaseDeepLink() {

        override fun equals(other: Any?): Boolean {
            return other is AssetOptInDeepLink && other.assetId == assetId
        }

        override fun hashCode(): Int {
            return assetId.hashCode()
        }

        companion object : DeepLinkCreator {
            override fun createDeepLink(rawDeeplink: RawDeepLink): BaseDeepLink {
                return rawDeeplink.assetId?.let { safeAssetId ->
                    AssetOptInDeepLink(safeAssetId)
                } ?: UndefinedDeepLink.create(rawDeeplink)
            }

            override fun doesDeeplinkMeetTheRequirements(rawDeepLink: RawDeepLink): Boolean {
                return with(rawDeepLink) {
                    val doesDeeplinkHaveAssetOptInQueries = assetId != null && BigInteger.ZERO.equals(amount)
                    doesDeeplinkHaveAssetOptInQueries &&
                        accountAddress == null &&
                        walletConnectUrl == null &&
                        note == null &&
                        xnote == null &&
                        label == null &&
                        webImportQrCode == null &&
                        notificationGroupType == null
                }
            }
        }
    }

    /**
     * ALGO transfer (public key, empty asset id, amount, note, xnote)
     * Examples;
     *  - algorand://WOLFYW4VEVVGEGVLQWEL4EMJ5SFCD3UCNKDH2DCUB5HQ6HLM6URZBMPXLI?amount=1000000&note=1_ALGO_Transfer
     *  - perawallet://WOLFYW4VEVVGEGVLQWEL4EMJ5SFCD3UCNKDH2DCUB5HQ6HLM6URZBMPXLI?amount=1000000&note=1_ALGO_Transfer
     *
     * ASA transfer (public key, asset ID, amount, note, xnote)
     *  - algorand://WOLFYW4VEVVGEGVLQWEL4EMJ5SFCD3UCNKDH2DCUB5HQ6HLM6URZBMPXLI?amount=1&asset=226701642&xnote=Uneditable_1_USDC_Transfer_Note
     *  - perawallet://WOLFYW4VEVVGEGVLQWEL4EMJ5SFCD3UCNKDH2DCUB5HQ6HLM6URZBMPXLI?amount=1&asset=226701642&xnote=Uneditable_1_USDC_Transfer_Note
     */
    class AssetTransferDeepLink private constructor(
        val assetId: Long,
        val receiverAccountAddress: String,
        val amount: BigInteger,
        val note: String?,
        val xnote: String?,
        val label: String?
    ) : BaseDeepLink() {

        override fun equals(other: Any?): Boolean {
            return other is AssetTransferDeepLink &&
                other.assetId == assetId &&
                other.receiverAccountAddress == receiverAccountAddress &&
                other.amount.isEqualTo(amount) &&
                other.note == note &&
                other.xnote == xnote &&
                other.label == label
        }

        override fun hashCode(): Int {
            var result = assetId.hashCode()
            result = 31 * result + receiverAccountAddress.hashCode()
            result = 31 * result + amount.hashCode()
            result = 31 * result + (note?.hashCode() ?: 0)
            result = 31 * result + (xnote?.hashCode() ?: 0)
            result = 31 * result + (label?.hashCode() ?: 0)
            return result
        }

        companion object : DeepLinkCreator {

            private const val DEFAULT_ASSET_ID = AssetInformation.ALGO_ID

            override fun createDeepLink(rawDeeplink: RawDeepLink): BaseDeepLink {
                return AssetTransferDeepLink(
                    receiverAccountAddress = rawDeeplink.accountAddress.orEmpty(),
                    amount = rawDeeplink.amount ?: BigInteger.valueOf(DEFAULT_AMOUNT),
                    note = rawDeeplink.note,
                    xnote = rawDeeplink.xnote,
                    assetId = rawDeeplink.assetId ?: DEFAULT_ASSET_ID,
                    label = rawDeeplink.label
                )
            }

            override fun doesDeeplinkMeetTheRequirements(rawDeepLink: RawDeepLink): Boolean {
                return with(rawDeepLink) {
                    val doesDeeplinkHaveAssetTransferQueries = accountAddress != null && assetId != null
                    doesDeeplinkHaveAssetTransferQueries && walletConnectUrl == null &&
                        webImportQrCode == null &&
                        notificationGroupType == null
                }
            }
        }
    }

    /**
     * Examples;
     * wc://wc:b562a118-0cbd-4f4f-92af-e58bf0a9dfb8@1?bridge=https%3A%2F%2Fwallet-connect-d.perawallet.app&key=672a4fbd212bfdbf6e0c8a858d9ab1577df169e7eac74c7175b9a3fd0faea889
     * perawallet-wc://wc:b562a118-0cbd-4f4f-92af-e58bf0a9dfb8@1?bridge=https%3A%2F%2Fwallet-connect-d.perawallet.app&key=672a4fbd212bfdbf6e0c8a858d9ab1577df169e7eac74c7175b9a3fd0faea889
     */
    class WalletConnectConnectionDeepLink private constructor(val url: String) : BaseDeepLink() {

        override fun equals(other: Any?): Boolean {
            return other is WalletConnectConnectionDeepLink && other.url == url
        }

        override fun hashCode(): Int {
            return url.hashCode()
        }

        companion object : DeepLinkCreator {
            override fun createDeepLink(rawDeeplink: RawDeepLink): BaseDeepLink {
                return WalletConnectConnectionDeepLink(url = rawDeeplink.walletConnectUrl ?: DEFAULT_WALLET_CONNECT_URL)
            }

            override fun doesDeeplinkMeetTheRequirements(rawDeepLink: RawDeepLink): Boolean {
                return with(rawDeepLink) {
                    walletConnectUrl != null &&
                        accountAddress == null &&
                        assetId == null &&
                        amount == null &&
                        note == null &&
                        xnote == null &&
                        label == null &&
                        webImportQrCode == null &&
                        notificationGroupType == null
                }
            }
        }
    }

    class MnemonicDeepLink(
        val mnemonic: String
    ) : BaseDeepLink() {

        override fun equals(other: Any?): Boolean {
            return other is MnemonicDeepLink && mnemonic == other.mnemonic
        }

        override fun hashCode(): Int {
            return mnemonic.hashCode()
        }

        companion object : DeepLinkCreator {

            override fun createDeepLink(rawDeeplink: RawDeepLink): BaseDeepLink {
                return MnemonicDeepLink(
                    mnemonic = rawDeeplink.mnemonic ?: DEFAULT_MNEMONIC
                )
            }

            override fun doesDeeplinkMeetTheRequirements(rawDeepLink: RawDeepLink): Boolean {
                return with(rawDeepLink) {
                    mnemonic != null &&
                        accountAddress == null &&
                        assetId == null &&
                        amount == null &&
                        walletConnectUrl == null &&
                        note == null &&
                        xnote == null &&
                        label == null &&
                        webImportQrCode == null &&
                        notificationGroupType == null
                }
            }
        }
    }

    class WebImportQrCodeDeepLink(
        val webImportQrCode: WebImportQrCode
    ) : BaseDeepLink() {

        companion object : DeepLinkCreator {
            override fun createDeepLink(rawDeeplink: RawDeepLink): BaseDeepLink {
                return WebImportQrCodeDeepLink(
                    webImportQrCode = rawDeeplink.webImportQrCode ?: WebImportQrCode(
                        DEFAULT_WEBIMPORT_BACKUPID,
                        DEFAULT_WEBIMPORT_ENCRYPTIONKEY
                    )
                )
            }

            override fun doesDeeplinkMeetTheRequirements(rawDeepLink: RawDeepLink): Boolean {
                return with(rawDeepLink) {
                    webImportQrCode != null &&
                        accountAddress == null &&
                        assetId == null &&
                        amount == null &&
                        walletConnectUrl == null &&
                        note == null &&
                        xnote == null &&
                        label == null &&
                        notificationGroupType == null &&
                        mnemonic == null
                }
            }
        }
    }

    class NotificationDeepLink(
        val address: String,
        val assetId: Long,
        val notificationGroupType: NotificationGroupType,
    ) : BaseDeepLink() {

        override fun equals(other: Any?): Boolean {
            return other is NotificationDeepLink &&
                other.address == address &&
                other.assetId == assetId &&
                other.notificationGroupType == notificationGroupType
        }

        override fun hashCode(): Int {
            var result = address.hashCode()
            result = 31 * result + assetId.hashCode()
            result = 31 * result + notificationGroupType.hashCode()
            return result
        }

        companion object : DeepLinkCreator {

            private const val DEFAULT_ASSET_ID = AssetInformation.ALGO_ID

            override fun createDeepLink(rawDeeplink: RawDeepLink): BaseDeepLink {
                return NotificationDeepLink(
                    address = rawDeeplink.accountAddress.orEmpty(),
                    assetId = getSafeAssetIdForResponse(rawDeeplink.assetId) ?: DEFAULT_ASSET_ID,
                    notificationGroupType = rawDeeplink.notificationGroupType ?: DEFAULT_NOTIFICATION_GROUP_TYPE
                )
            }

            override fun doesDeeplinkMeetTheRequirements(rawDeepLink: RawDeepLink): Boolean {
                return with(rawDeepLink) {
                    accountAddress != null &&
                        assetId != null &&
                        notificationGroupType != null &&
                        amount == null &&
                        walletConnectUrl == null &&
                        note == null &&
                        xnote == null &&
                        label == null &&
                        webImportQrCode == null
                }
            }
        }
    }

    class UndefinedDeepLink private constructor(val rawDeepLink: RawDeepLink) : BaseDeepLink() {

        override fun equals(other: Any?): Boolean {
            return other is UndefinedDeepLink && rawDeepLink == other.rawDeepLink
        }

        override fun hashCode(): Int {
            return rawDeepLink.hashCode()
        }

        companion object {
            fun create(rawDeepLink: RawDeepLink) = UndefinedDeepLink(rawDeepLink)
        }
    }
}
