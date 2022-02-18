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

package com.algorand.android.utils

import android.content.Intent
import androidx.fragment.app.FragmentManager
import androidx.navigation.NavController
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.models.Account
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.NotificationType
import com.algorand.android.models.User

const val SELECTED_ACCOUNT_KEY = "selectedAccountKey"
const val SELECTED_ASSET_ID_KEY = "selectedAssetIdKey"
const val ASSET_SUPPORT_REQUESTED_PUBLIC_KEY = "supportRequestedPublicKey"
const val ASSET_SUPPORT_REQUESTED_ASSET_KEY = "supportRequestedAsset"
const val DEEPLINK_AND_NAVIGATION_INTENT = "deeplinknavIntent"
private const val NO_VALUE = -1L

private fun NavController.handleSelectedAssetNavigation(
    accountCacheManager: AccountCacheManager,
    selectedAccountKey: String,
    selectedAssetId: Long
) {
    val selectedAccountCacheData = accountCacheManager.getCacheData(selectedAccountKey)
    val selectedAssetInformation = accountCacheManager.getAssetInformation(selectedAccountKey, selectedAssetId)
    if (selectedAccountCacheData != null && selectedAssetInformation != null) {
//        navigateSafe( TODO Check here before merging
//            AccountsFragmentDirections.actionAccountsFragmentToAssetDetailFragment(
//                selectedAssetInformation, selectedAccountCacheData.account.address
//            )
//        )
    }
}

fun NavController.handleDeeplink(
    decodedQrCode: DecodedQrCode,
    accountCacheManager: AccountCacheManager,
    onWalletConnectResult: ((String) -> Unit?)? = null
): Boolean {

    if (decodedQrCode.walletConnectUrl != null) {
        onWalletConnectResult?.invoke(decodedQrCode.walletConnectUrl)
        return true
    }

    if (decodedQrCode.address == null) {
        return false
    }

    if (decodedQrCode.amount != null) {
        // If deeplink does not contain assetId then it should be Algo
        val assetId = decodedQrCode.getDecodedAssetID()

        val accountAssetPairList = accountCacheManager.getAccountCacheWithSpecificAsset(
            assetId, listOf(Account.Type.WATCH)
        )

        if (accountAssetPairList.isEmpty()) {
            val assetAction = AssetAction(assetId = assetId)
            // No account owns this asset
            navigateSafe(HomeNavigationDirections.actionGlobalUnsupportedAddAssetTryLaterBottomSheet(assetAction))
            return false
        }

        val assetTransaction = AssetTransaction(
            assetId = assetId,
            note = decodedQrCode.note, // normal note
            xnote = decodedQrCode.xnote, // locked note
            amount = decodedQrCode.amount,
            receiverUser = User(
                publicKey = decodedQrCode.address,
                name = decodedQrCode.label ?: decodedQrCode.address,
                imageUriAsString = null
            )
        )
        navigateSafe(HomeNavigationDirections.actionGlobalSendAlgoNavigation(assetTransaction))
    } else {
        // If deeplink does not contain amount information then it should be navigate to account addition flow
        navigateSafe(
            HomeNavigationDirections.actionGlobalAddContactFragment(
                contactName = decodedQrCode.label,
                contactPublicKey = decodedQrCode.address
            )
        )
    }
    return true
}

fun NavController.handleIntent(
    intentToHandle: Intent,
    accountCacheManager: AccountCacheManager,
    fragmentManager: FragmentManager,
    onWalletConnectResult: (String) -> Unit
): Boolean {
    with(intentToHandle) {
        return when {
            dataString != null -> {
                val decodedDeeplink = decodeDeeplink(dataString) ?: return false
                handleDeeplink(decodedDeeplink, accountCacheManager, onWalletConnectResult)
            }
            else -> handleIntentWithBundle(this, accountCacheManager)
        }
    }
}

private fun NavController.handleIntentWithBundle(
    intentToHandle: Intent,
    accountCacheManager: AccountCacheManager
): Boolean {
    with(intentToHandle) {
        // TODO change your architecture for the bug here. https://issuetracker.google.com/issues/37053389
        // This fixes the problem for now. Be careful when adding more than one parcelable.
        setExtrasClassLoader(AssetInformation::class.java.classLoader)

        val selectedAssetToOpen = getLongExtra(SELECTED_ASSET_ID_KEY, NO_VALUE)
        val selectedPublicKeyToOpen = getStringExtra(SELECTED_ACCOUNT_KEY)

        if (!selectedPublicKeyToOpen.isNullOrBlank() && selectedAssetToOpen != NO_VALUE) {
            handleSelectedAssetNavigation(accountCacheManager, selectedPublicKeyToOpen, selectedAssetToOpen)
            return true
        }

        val assetSupportRequestedPublicKey = getStringExtra(ASSET_SUPPORT_REQUESTED_PUBLIC_KEY)
        val assetSupportRequestedAsset =
            getParcelableExtra<AssetInformation>(ASSET_SUPPORT_REQUESTED_ASSET_KEY)

        if (!assetSupportRequestedPublicKey.isNullOrBlank() && assetSupportRequestedAsset != null) {
            val assetAction = AssetAction(
                assetId = assetSupportRequestedAsset.assetId,
                publicKey = assetSupportRequestedPublicKey,
                asset = assetSupportRequestedAsset
            )
            navigateSafe(
                HomeNavigationDirections.actionGlobalUnsupportedAssetNotificationRequestActionBottomSheet(assetAction)
            )
            return true
        }
    }
    return false
}

// TODO change according to notification type later on.
fun NavController.isNotificationCanBeShown(notificationType: NotificationType, isAppUnlocked: Boolean): Boolean {
    if (isAppUnlocked) {
        return true
    }
    return false
}
