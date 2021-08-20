/*
 * Copyright 2019 Algorand, Inc.
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
import com.algorand.android.HomeNavigationDirections.Companion.actionGlobalAddContactFragment
import com.algorand.android.HomeNavigationDirections.Companion.actionGlobalSendInfoFragment
import com.algorand.android.models.Account
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.NotificationType
import com.algorand.android.ui.accounts.AccountsFragmentDirections
import com.algorand.android.ui.common.AssetActionBottomSheet

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
        navigateSafe(
            AccountsFragmentDirections.actionAccountsFragmentToAssetDetailFragment(
                selectedAssetInformation, selectedAccountCacheData.account.address
            )
        )
    }
}

fun NavController.handleDeeplink(
    decodedQrCode: DecodedQrCode,
    accountCacheManager: AccountCacheManager,
    fragmentManager: FragmentManager,
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
        val assetId = decodedQrCode.getDecodedAssetID()
        val accountAssetPairList = accountCacheManager.getAccountCacheWithSpecificAsset(
            assetId, listOf(Account.Type.WATCH)
        )

        if (accountAssetPairList.isEmpty()) {
            AssetActionBottomSheet.show(
                fragmentManager,
                assetId,
                AssetActionBottomSheet.Type.UNSUPPORTED_ADD_TRY_LATER
            )
            return false
        }

        navigateSafe(
            actionGlobalSendInfoFragment(
                assetInformation = accountAssetPairList.first().second,
                amount = decodedQrCode.amount,
                note = decodedQrCode.note,
                xnote = decodedQrCode.xnote,
                toAccountAddress = decodedQrCode.address
            )
        )
    } else {
        navigateSafe(
            actionGlobalAddContactFragment(
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
                handleDeeplink(decodedDeeplink, accountCacheManager, fragmentManager, onWalletConnectResult)
            }
            else -> handleIntentWithBundle(this, accountCacheManager, fragmentManager)
        }
    }
}

private fun NavController.handleIntentWithBundle(
    intentToHandle: Intent,
    accountCacheManager: AccountCacheManager,
    fragmentManager: FragmentManager
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
            AssetActionBottomSheet.show(
                fragmentManager,
                assetSupportRequestedAsset.assetId,
                AssetActionBottomSheet.Type.UNSUPPORTED_NOTIFICATION_REQUEST,
                assetSupportRequestedPublicKey,
                assetSupportRequestedAsset
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
