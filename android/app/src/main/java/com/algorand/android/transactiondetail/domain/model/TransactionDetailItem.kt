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

package com.algorand.android.transactiondetail.domain.model

import android.net.Uri
import androidx.annotation.StringRes
import com.algorand.android.models.AccountIcon
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.utils.AssetName
import java.math.BigInteger

sealed class TransactionDetailItem : RecyclerListItem {

    enum class ItemType {
        TRANSACTION_AMOUNT_ITEM,
        CLOSE_TO_AMOUNT_ITEM,
        FEE_AMOUNT_ITEM,
        REWARD_AMOUNT_ITEM,
        ACCOUNT_ITEM,
        STATUS_ITEM,
        DATE_ITEM,
        TRANSACTION_ID_ITEM,
        NOTE_ITEM,
        CHIP_GROUP_ITEM,
        DIVIDER_ITEM
    }

    abstract val itemType: ItemType

    sealed class AmountItem : TransactionDetailItem() {

        abstract val labelTextRes: Int
        abstract val transactionSign: TransactionSign
        abstract val transactionAmount: BigInteger
        abstract val formattedTransactionAmount: String
        abstract val assetName: AssetName

        data class TransactionAmountItem(
            @StringRes
            override val labelTextRes: Int,
            override val transactionSign: TransactionSign,
            override val transactionAmount: BigInteger,
            override val formattedTransactionAmount: String,
            override val assetName: AssetName
        ) : AmountItem() {

            override val itemType: ItemType = ItemType.TRANSACTION_AMOUNT_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is TransactionAmountItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is TransactionAmountItem && this == other
            }
        }

        data class CloseAmountItem(
            @StringRes
            override val labelTextRes: Int,
            override val transactionSign: TransactionSign,
            override val transactionAmount: BigInteger,
            override val formattedTransactionAmount: String,
            override val assetName: AssetName
        ) : AmountItem() {

            override val itemType: ItemType = ItemType.CLOSE_TO_AMOUNT_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is CloseAmountItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is CloseAmountItem && this == other
            }
        }

        data class RewardItem(
            @StringRes
            override val labelTextRes: Int,
            override val transactionSign: TransactionSign,
            override val transactionAmount: BigInteger,
            override val formattedTransactionAmount: String,
            override val assetName: AssetName
        ) : AmountItem() {

            override val itemType: ItemType = ItemType.REWARD_AMOUNT_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is RewardItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is RewardItem && this == other
            }
        }

        data class FeeItem(
            @StringRes
            override val labelTextRes: Int,
            override val transactionSign: TransactionSign,
            override val transactionAmount: BigInteger,
            override val formattedTransactionAmount: String,
            override val assetName: AssetName
        ) : AmountItem() {

            override val itemType: ItemType = ItemType.FEE_AMOUNT_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is FeeItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is FeeItem && this == other
            }
        }
    }

    sealed class AccountItem : TransactionDetailItem() {

        abstract val labelTextRes: Int
        abstract val displayAddress: String
        abstract val publicKey: String
        abstract val isAccountAdditionButtonVisible: Boolean
        abstract val isCopyButtonVisible: Boolean
        abstract val showToolTipView: Boolean

        override val itemType: ItemType = ItemType.ACCOUNT_ITEM

        data class WalletItem(
            @StringRes
            override val labelTextRes: Int,
            override val displayAddress: String,
            override val publicKey: String,
            override val isAccountAdditionButtonVisible: Boolean,
            override val isCopyButtonVisible: Boolean,
            override val showToolTipView: Boolean,
            val accountIcon: AccountIcon
        ) : AccountItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is WalletItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is WalletItem && this == other
            }
        }

        data class ContactItem(
            @StringRes
            override val labelTextRes: Int,
            override val displayAddress: String,
            override val publicKey: String,
            override val isAccountAdditionButtonVisible: Boolean,
            override val isCopyButtonVisible: Boolean,
            override val showToolTipView: Boolean,
            val contactUri: Uri?
        ) : AccountItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is ContactItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is ContactItem && this == other
            }
        }

        data class NormalItem(
            @StringRes
            override val labelTextRes: Int,
            override val displayAddress: String,
            override val publicKey: String,
            override val isAccountAdditionButtonVisible: Boolean,
            override val isCopyButtonVisible: Boolean,
            override val showToolTipView: Boolean
        ) : AccountItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is NormalItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is NormalItem && this == other
            }
        }
    }

    sealed class StatusItem : TransactionDetailItem() {

        abstract val transactionStatusTextRes: Int
        abstract val transactionStatusBackgroundRes: Int
        abstract val transactionStatusTextStyleRes: Int
        abstract val transactionStatusTextColorRes: Int
        abstract val labelTextRes: Int

        override val itemType: ItemType = ItemType.STATUS_ITEM

        data class PendingItem(
            override val transactionStatusTextRes: Int,
            override val transactionStatusBackgroundRes: Int,
            override val labelTextRes: Int,
            override val transactionStatusTextStyleRes: Int,
            override val transactionStatusTextColorRes: Int
        ) : StatusItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is PendingItem && transactionStatusTextRes == other.transactionStatusTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is PendingItem && this == other
            }
        }

        data class FailedItem(
            override val transactionStatusTextRes: Int,
            override val transactionStatusBackgroundRes: Int,
            override val labelTextRes: Int,
            override val transactionStatusTextStyleRes: Int,
            override val transactionStatusTextColorRes: Int
        ) : StatusItem() {

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is FailedItem && transactionStatusTextRes == other.transactionStatusTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is FailedItem && this == other
            }
        }

        data class SuccessItem(
            override val transactionStatusTextRes: Int,
            override val transactionStatusBackgroundRes: Int,
            override val labelTextRes: Int,
            override val transactionStatusTextStyleRes: Int,
            override val transactionStatusTextColorRes: Int
        ) : StatusItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is SuccessItem && transactionStatusTextRes == other.transactionStatusTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is SuccessItem && this == other
            }
        }
    }

    data class DateItem(
        @StringRes
        val labelTextRes: Int,
        val date: String
    ) : TransactionDetailItem() {

        override val itemType: ItemType = ItemType.DATE_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is DateItem && labelTextRes == other.labelTextRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is DateItem && this == other
        }
    }

    data class TransactionIdItem(
        @StringRes
        val labelTextRes: Int,
        val transactionId: String
    ) : TransactionDetailItem() {

        override val itemType: ItemType = ItemType.TRANSACTION_ID_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TransactionIdItem && labelTextRes == other.labelTextRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TransactionIdItem && this == other
        }
    }

    data class NoteItem(
        @StringRes
        val labelTextRes: Int,
        val note: String
    ) : TransactionDetailItem() {

        override val itemType: ItemType = ItemType.NOTE_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is NoteItem && labelTextRes == other.labelTextRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is NoteItem && this == other
        }
    }

    data class ChipGroupItem(
        val transactionId: String,
        val algoExplorerUrl: String,
        val goalSeekerUrl: String
    ) : TransactionDetailItem() {

        override val itemType: ItemType = ItemType.CHIP_GROUP_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is ChipGroupItem && transactionId == other.transactionId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is ChipGroupItem && transactionId == other.transactionId
        }
    }

    object DividerItem : TransactionDetailItem() {

        override val itemType: ItemType = ItemType.DIVIDER_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is DividerItem && this == other
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is DividerItem && this == other
        }
    }
}
