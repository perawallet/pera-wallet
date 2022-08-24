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

package com.algorand.android.modules.transaction.detail.ui.mapper

import android.net.Uri
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import androidx.annotation.StyleRes
import com.algorand.android.models.AccountIconResource
import com.algorand.android.modules.transaction.detail.domain.model.BaseTransactionDetail
import com.algorand.android.modules.transaction.detail.domain.model.TransactionSign
import com.algorand.android.modules.transaction.detail.ui.model.ApplicationCallAssetInformation
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem
import com.algorand.android.utils.AssetName
import java.math.BigInteger
import javax.inject.Inject

class TransactionDetailItemMapper @Inject constructor() {

    fun mapToNoteItem(@StringRes labelTextRes: Int, note: String): TransactionDetailItem.NoteItem {
        return TransactionDetailItem.NoteItem(labelTextRes = labelTextRes, note = note)
    }

    fun mapToTransactionIdItem(
        @StringRes labelTextRes: Int,
        transactionId: String
    ): TransactionDetailItem.StandardTransactionItem.TransactionIdItem {
        return TransactionDetailItem.StandardTransactionItem.TransactionIdItem(
            labelTextRes = labelTextRes,
            transactionId = transactionId
        )
    }

    fun mapToDateItem(
        @StringRes labelTextRes: Int,
        date: String
    ): TransactionDetailItem.StandardTransactionItem.DateItem {
        return TransactionDetailItem.StandardTransactionItem.DateItem(labelTextRes = labelTextRes, date = date)
    }

    fun mapToPendingStatusItem(
        @StringRes transactionStatusTextRes: Int,
        @DrawableRes transactionStatusBackgroundColor: Int,
        @StringRes labelTextRes: Int,
        @StyleRes transactionStatusTextStyleRes: Int,
        @ColorRes transactionStatusTextColorRes: Int
    ): TransactionDetailItem.StandardTransactionItem.StatusItem.PendingItem {
        return TransactionDetailItem.StandardTransactionItem.StatusItem.PendingItem(
            transactionStatusTextRes = transactionStatusTextRes,
            transactionStatusBackgroundRes = transactionStatusBackgroundColor,
            labelTextRes = labelTextRes,
            transactionStatusTextStyleRes = transactionStatusTextStyleRes,
            transactionStatusTextColorRes = transactionStatusTextColorRes
        )
    }

    fun mapToFailedStatusItem(
        @StringRes transactionStatusTextRes: Int,
        @DrawableRes transactionStatusBackgroundColor: Int,
        @StringRes labelTextRes: Int,
        @StyleRes transactionStatusTextStyleRes: Int,
        @ColorRes transactionStatusTextColorRes: Int
    ): TransactionDetailItem.StandardTransactionItem.StatusItem.FailedItem {
        return TransactionDetailItem.StandardTransactionItem.StatusItem.FailedItem(
            transactionStatusTextRes = transactionStatusTextRes,
            transactionStatusBackgroundRes = transactionStatusBackgroundColor,
            labelTextRes = labelTextRes,
            transactionStatusTextStyleRes = transactionStatusTextStyleRes,
            transactionStatusTextColorRes = transactionStatusTextColorRes
        )
    }

    fun mapToSuccessStatusItem(
        @StringRes transactionStatusTextRes: Int,
        @DrawableRes transactionStatusBackgroundColor: Int,
        @StringRes labelTextRes: Int,
        @StyleRes transactionStatusTextStyleRes: Int,
        @ColorRes transactionStatusTextColorRes: Int
    ): TransactionDetailItem.StandardTransactionItem.StatusItem.SuccessItem {
        return TransactionDetailItem.StandardTransactionItem.StatusItem.SuccessItem(
            transactionStatusTextRes = transactionStatusTextRes,
            transactionStatusBackgroundRes = transactionStatusBackgroundColor,
            labelTextRes = labelTextRes,
            transactionStatusTextStyleRes = transactionStatusTextStyleRes,
            transactionStatusTextColorRes = transactionStatusTextColorRes
        )
    }

    fun mapToWalletAccountItem(
        @StringRes labelTextRes: Int,
        displayAddress: String,
        publicKey: String,
        isAccountAdditionButtonVisible: Boolean,
        isCopyButtonVisible: Boolean,
        accountIconResource: AccountIconResource,
        showToolTipView: Boolean
    ): TransactionDetailItem.StandardTransactionItem.AccountItem.WalletItem {
        return TransactionDetailItem.StandardTransactionItem.AccountItem.WalletItem(
            labelTextRes = labelTextRes,
            displayAddress = displayAddress,
            publicKey = publicKey,
            isAccountAdditionButtonVisible = isAccountAdditionButtonVisible,
            isCopyButtonVisible = isCopyButtonVisible,
            accountIconResource = accountIconResource,
            showToolTipView = showToolTipView
        )
    }

    fun mapToContactAccountItem(
        @StringRes labelTextRes: Int,
        displayAddress: String,
        publicKey: String,
        isAccountAdditionButtonVisible: Boolean,
        isCopyButtonVisible: Boolean,
        contactUri: Uri?,
        showToolTipView: Boolean
    ): TransactionDetailItem.StandardTransactionItem.AccountItem.ContactItem {
        return TransactionDetailItem.StandardTransactionItem.AccountItem.ContactItem(
            labelTextRes = labelTextRes,
            displayAddress = displayAddress,
            publicKey = publicKey,
            isAccountAdditionButtonVisible = isAccountAdditionButtonVisible,
            isCopyButtonVisible = isCopyButtonVisible,
            contactUri = contactUri,
            showToolTipView = showToolTipView
        )
    }

    fun mapToNormalAccountItem(
        @StringRes labelTextRes: Int,
        displayAddress: String,
        publicKey: String,
        isAccountAdditionButtonVisible: Boolean,
        isCopyButtonVisible: Boolean,
        showToolTipView: Boolean
    ): TransactionDetailItem.StandardTransactionItem.AccountItem.NormalItem {
        return TransactionDetailItem.StandardTransactionItem.AccountItem.NormalItem(
            labelTextRes = labelTextRes,
            displayAddress = displayAddress,
            publicKey = publicKey,
            isAccountAdditionButtonVisible = isAccountAdditionButtonVisible,
            isCopyButtonVisible = isCopyButtonVisible,
            showToolTipView = showToolTipView
        )
    }

    fun mapToTransactionAmountItem(
        @StringRes labelTextRes: Int,
        transactionSign: TransactionSign,
        transactionAmount: BigInteger,
        formattedTransactionAmount: String,
        assetName: AssetName
    ): TransactionDetailItem.StandardTransactionItem.TransactionAmountItem {
        return TransactionDetailItem.StandardTransactionItem.TransactionAmountItem(
            labelTextRes = labelTextRes,
            transactionSign = transactionSign,
            transactionAmount = transactionAmount,
            formattedTransactionAmount = formattedTransactionAmount,
            assetName = assetName
        )
    }

    fun mapToCloseAmountItem(
        @StringRes labelTextRes: Int,
        transactionSign: TransactionSign,
        transactionAmount: BigInteger,
        formattedTransactionAmount: String,
        assetName: AssetName
    ): TransactionDetailItem.StandardTransactionItem.CloseAmountItem {
        return TransactionDetailItem.StandardTransactionItem.CloseAmountItem(
            labelTextRes = labelTextRes,
            transactionSign = transactionSign,
            transactionAmount = transactionAmount,
            formattedTransactionAmount = formattedTransactionAmount,
            assetName = assetName
        )
    }

    fun mapToFeeItem(
        @StringRes labelTextRes: Int,
        transactionSign: TransactionSign,
        transactionAmount: BigInteger,
        formattedTransactionAmount: String,
        assetName: AssetName
    ): TransactionDetailItem.FeeItem {
        return TransactionDetailItem.FeeItem(
            labelTextRes = labelTextRes,
            transactionSign = transactionSign,
            transactionAmount = transactionAmount,
            formattedTransactionAmount = formattedTransactionAmount,
            assetName = assetName
        )
    }

    fun mapToChipGroupItem(
        transactionId: String,
        goalSeekerUrl: String,
        algoExplorerUrl: String
    ): TransactionDetailItem.ChipGroupItem {
        return TransactionDetailItem.ChipGroupItem(
            transactionId = transactionId,
            algoExplorerUrl = algoExplorerUrl,
            goalSeekerUrl = goalSeekerUrl
        )
    }

    fun mapToSenderItem(
        @StringRes labelTextRes: Int,
        senderAccountAddress: String
    ): TransactionDetailItem.ApplicationCallItem.SenderItem {
        return TransactionDetailItem.ApplicationCallItem.SenderItem(
            labelTextRes = labelTextRes,
            senderAccountAddress = senderAccountAddress
        )
    }

    fun mapToApplicationIdItem(
        @StringRes labelTextRes: Int,
        applicationId: Long
    ): TransactionDetailItem.ApplicationCallItem.ApplicationIdItem {
        return TransactionDetailItem.ApplicationCallItem.ApplicationIdItem(
            labelTextRes = labelTextRes,
            applicationId = applicationId
        )
    }

    fun mapToOnCompletionItem(
        @StringRes labelTextRes: Int,
        onCompletionTextRes: Int?
    ): TransactionDetailItem.ApplicationCallItem.OnCompletionItem {
        return TransactionDetailItem.ApplicationCallItem.OnCompletionItem(
            labelTextRes = labelTextRes,
            onCompletionTextRes = onCompletionTextRes
        )
    }

    fun mapToApplicationCallAssetInformationItem(
        @PluralsRes labelTextRes: Int,
        assetInformationList: List<ApplicationCallAssetInformation>,
        showMoreButton: Boolean,
        showMoreAssetCount: Int
    ): TransactionDetailItem.ApplicationCallItem.AppCallAssetInformationItem {
        return TransactionDetailItem.ApplicationCallItem.AppCallAssetInformationItem(
            labelTextRes = labelTextRes,
            assetInformationList = assetInformationList,
            showMoreButton = showMoreButton,
            showMoreAssetCount = showMoreAssetCount
        )
    }

    fun mapToAssetInformationItem(
        assetFullName: AssetName,
        assetShortName: AssetName,
        assetId: Long
    ): TransactionDetailItem.StandardTransactionItem.AssetInformationItem {
        return TransactionDetailItem.StandardTransactionItem.AssetInformationItem(
            assetFullName = assetFullName,
            assetShortName = assetShortName,
            assetId = assetId
        )
    }

    fun mapToInnerTransactionListItem(
        @StringRes labelTextRes: Int,
        innerTransactionCount: Int,
        innerTransactions: List<BaseTransactionDetail>?
    ): TransactionDetailItem.ApplicationCallItem.InnerTransactionCountItem {
        return TransactionDetailItem.ApplicationCallItem.InnerTransactionCountItem(
            labelTextRes = labelTextRes,
            innerTransactionCount = innerTransactionCount,
            innerTransactions = innerTransactions
        )
    }

    fun mapToInnerTransactionTitleItem(
        innerTransactionCount: Int
    ): TransactionDetailItem.InnerTransactionItem.InnerTransactionTitleItem {
        return TransactionDetailItem.InnerTransactionItem.InnerTransactionTitleItem(
            innerTransactionCount = innerTransactionCount
        )
    }

    fun mapToApplicationInnerTransactionItem(
        accountAddress: String,
        transactionSign: TransactionSign,
        innerTransactionCount: Int,
        transaction: BaseTransactionDetail.ApplicationCallTransaction
    ): TransactionDetailItem.InnerTransactionItem.ApplicationInnerTransactionItem {
        return TransactionDetailItem.InnerTransactionItem.ApplicationInnerTransactionItem(
            accountAddress = accountAddress,
            transactionSign = transactionSign,
            innerTransactionCount = innerTransactionCount,
            transaction = transaction
        )
    }

    fun mapToStandardInnerTransactionItem(
        accountAddress: String,
        transactionSign: TransactionSign,
        transactionAmount: BigInteger,
        formattedTransactionAmount: String,
        transaction: BaseTransactionDetail
    ): TransactionDetailItem.InnerTransactionItem.StandardInnerTransactionItem {
        return TransactionDetailItem.InnerTransactionItem.StandardInnerTransactionItem(
            accountAddress = accountAddress,
            transactionSign = transactionSign,
            transactionAmount = transactionAmount,
            formattedTransactionAmount = formattedTransactionAmount,
            transaction = transaction
        )
    }
}
