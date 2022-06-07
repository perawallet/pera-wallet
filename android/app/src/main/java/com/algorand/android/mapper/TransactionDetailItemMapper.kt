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

package com.algorand.android.mapper

import android.net.Uri
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.annotation.StyleRes
import com.algorand.android.models.AccountIcon
import com.algorand.android.transactiondetail.domain.model.TransactionDetailItem
import com.algorand.android.transactiondetail.domain.model.TransactionSign
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
    ): TransactionDetailItem.TransactionIdItem {
        return TransactionDetailItem.TransactionIdItem(labelTextRes = labelTextRes, transactionId = transactionId)
    }

    fun mapToDateItem(@StringRes labelTextRes: Int, date: String): TransactionDetailItem.DateItem {
        return TransactionDetailItem.DateItem(labelTextRes = labelTextRes, date = date)
    }

    fun mapToDividerItem(): TransactionDetailItem.DividerItem {
        return TransactionDetailItem.DividerItem
    }

    fun mapToPendingStatusItem(
        @StringRes transactionStatusTextRes: Int,
        @DrawableRes transactionStatusBackgroundColor: Int,
        @StringRes labelTextRes: Int,
        @StyleRes transactionStatusTextStyleRes: Int,
        @ColorRes transactionStatusTextColorRes: Int
    ): TransactionDetailItem.StatusItem.PendingItem {
        return TransactionDetailItem.StatusItem.PendingItem(
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
    ): TransactionDetailItem.StatusItem.FailedItem {
        return TransactionDetailItem.StatusItem.FailedItem(
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
    ): TransactionDetailItem.StatusItem.SuccessItem {
        return TransactionDetailItem.StatusItem.SuccessItem(
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
        accountIcon: AccountIcon,
        showToolTipView: Boolean
    ): TransactionDetailItem.AccountItem.WalletItem {
        return TransactionDetailItem.AccountItem.WalletItem(
            labelTextRes = labelTextRes,
            displayAddress = displayAddress,
            publicKey = publicKey,
            isAccountAdditionButtonVisible = isAccountAdditionButtonVisible,
            isCopyButtonVisible = isCopyButtonVisible,
            accountIcon = accountIcon,
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
    ): TransactionDetailItem.AccountItem.ContactItem {
        return TransactionDetailItem.AccountItem.ContactItem(
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
    ): TransactionDetailItem.AccountItem.NormalItem {
        return TransactionDetailItem.AccountItem.NormalItem(
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
    ): TransactionDetailItem.AmountItem.TransactionAmountItem {
        return TransactionDetailItem.AmountItem.TransactionAmountItem(
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
    ): TransactionDetailItem.AmountItem.CloseAmountItem {
        return TransactionDetailItem.AmountItem.CloseAmountItem(
            labelTextRes = labelTextRes,
            transactionSign = transactionSign,
            transactionAmount = transactionAmount,
            formattedTransactionAmount = formattedTransactionAmount,
            assetName = assetName
        )
    }

    fun mapToRewardItem(
        @StringRes labelTextRes: Int,
        transactionSign: TransactionSign,
        transactionAmount: BigInteger,
        formattedTransactionAmount: String,
        assetName: AssetName
    ): TransactionDetailItem.AmountItem.RewardItem {
        return TransactionDetailItem.AmountItem.RewardItem(
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
    ): TransactionDetailItem.AmountItem.FeeItem {
        return TransactionDetailItem.AmountItem.FeeItem(
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
}
