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

package com.algorand.android.modules.transaction.detail.ui.model

import android.net.Uri
import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.transaction.detail.domain.model.BaseTransactionDetail
import com.algorand.android.modules.transaction.detail.domain.model.TransactionSign
import com.algorand.android.utils.AssetName
import java.math.BigInteger

sealed class TransactionDetailItem : RecyclerListItem {

    enum class ItemType {
        TRANSACTION_AMOUNT_ITEM,
        CLOSE_TO_AMOUNT_ITEM,
        FEE_AMOUNT_ITEM,
        ACCOUNT_ITEM,
        STATUS_ITEM,
        DATE_ITEM,
        ROUND_ITEM,
        TRANSACTION_ID_ITEM,
        NOTE_ITEM,
        CHIP_GROUP_ITEM,
        DIVIDER_ITEM,
        SENDER_ITEM,
        APPLICATION_ID_ITEM,
        ON_COMPLETION_ITEM,
        APPLICATION_CALL_ASSET_INFORMATION_ITEM,
        INNER_TRANSACTION_LIST_ITEM,
        INNER_TRANSACTION_TITLE_ITEM,
        INNER_STANDARD_TRANSACTION_DETAIL_ITEM,
        INNER_APPLICATION_CALL_TRANSACTION_DETAIL_ITEM,
        ASSET_INFORMATION_ITEM,
        ONLINE_KEY_REG_ITEM,
        OFFLINE_KEY_REG_ITEM
    }

    abstract val itemType: ItemType

    data class FeeItem(
        @StringRes
        val labelTextRes: Int,
        val transactionSign: TransactionSign,
        val transactionAmount: BigInteger,
        val formattedTransactionAmount: String,
        val assetName: AssetName
    ) : TransactionDetailItem() {

        override val itemType: ItemType = ItemType.FEE_AMOUNT_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is FeeItem && labelTextRes == other.labelTextRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is FeeItem && this == other
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
        val peraExplorerUrl: String,
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

    sealed class InnerTransactionItem : TransactionDetailItem() {

        data class InnerTransactionTitleItem(val innerTransactionCount: Int) : InnerTransactionItem() {

            override val itemType: ItemType = ItemType.INNER_TRANSACTION_TITLE_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is InnerTransactionTitleItem && innerTransactionCount == other.innerTransactionCount
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is InnerTransactionTitleItem && other == this
            }
        }

        data class StandardInnerTransactionItem(
            val accountAddress: String,
            val transactionSign: TransactionSign,
            val transactionAmount: BigInteger,
            val formattedTransactionAmount: String,
            val transaction: BaseTransactionDetail
        ) : InnerTransactionItem() {

            override val itemType: ItemType = ItemType.INNER_STANDARD_TRANSACTION_DETAIL_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is StandardInnerTransactionItem &&
                    transactionAmount == other.transactionAmount &&
                    accountAddress == other.accountAddress
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is StandardInnerTransactionItem && this == other
            }
        }

        data class ApplicationInnerTransactionItem(
            val accountAddress: String,
            val transactionSign: TransactionSign,
            val innerTransactionCount: Int,
            val transaction: BaseTransactionDetail.ApplicationCallTransaction
        ) : InnerTransactionItem() {

            override val itemType: ItemType = ItemType.INNER_APPLICATION_CALL_TRANSACTION_DETAIL_ITEM

            fun hasInnerTransaction(): Boolean {
                return innerTransactionCount > 0
            }

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is StandardInnerTransactionItem && accountAddress == other.accountAddress
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is StandardInnerTransactionItem && this == other
            }
        }
    }

    sealed class ApplicationCallItem : TransactionDetailItem() {

        data class SenderItem(
            @StringRes
            val labelTextRes: Int,
            val senderAccountAddress: String
        ) : ApplicationCallItem() {

            override val itemType: ItemType = ItemType.SENDER_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is SenderItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is SenderItem && this == other
            }
        }

        data class ApplicationIdItem(
            @StringRes
            val labelTextRes: Int,
            val applicationId: Long
        ) : ApplicationCallItem() {

            override val itemType: ItemType = ItemType.APPLICATION_ID_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is ApplicationIdItem && applicationId == other.applicationId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is ApplicationIdItem && this == other
            }
        }

        data class OnCompletionItem(
            @StringRes
            val labelTextRes: Int,
            @StringRes
            val onCompletionTextRes: Int?
        ) : ApplicationCallItem() {

            override val itemType: ItemType = ItemType.ON_COMPLETION_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is OnCompletionItem && onCompletionTextRes == other.onCompletionTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is OnCompletionItem && this == other
            }
        }

        data class AppCallAssetInformationItem(
            @PluralsRes
            val labelTextRes: Int,
            val assetInformationList: List<ApplicationCallAssetInformation>,
            val showMoreButton: Boolean,
            val showMoreAssetCount: Int
        ) : ApplicationCallItem() {

            override val itemType: ItemType = ItemType.APPLICATION_CALL_ASSET_INFORMATION_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is AppCallAssetInformationItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is AppCallAssetInformationItem && this == other
            }
        }

        data class InnerTransactionCountItem(
            @StringRes
            val labelTextRes: Int,
            val innerTransactionCount: Int,
            val innerTransactions: List<BaseTransactionDetail>?
        ) : ApplicationCallItem() {

            override val itemType: ItemType = ItemType.INNER_TRANSACTION_LIST_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is InnerTransactionCountItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is InnerTransactionCountItem && this == other
            }
        }
    }

    sealed class StandardTransactionItem : TransactionDetailItem() {

        data class TransactionAmountItem(
            @StringRes
            val labelTextRes: Int,
            val transactionSign: TransactionSign,
            val transactionAmount: BigInteger,
            val formattedTransactionAmount: String,
            val assetName: AssetName
        ) : StandardTransactionItem() {

            override val itemType: ItemType = ItemType.TRANSACTION_AMOUNT_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is TransactionAmountItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is TransactionAmountItem && this == other
            }
        }

        data class AssetInformationItem(
            val assetFullName: AssetName,
            val assetShortName: AssetName,
            val assetId: Long
        ) : TransactionDetailItem() {

            val labelTextRes: Int
                get() = R.string.asset

            override val itemType: ItemType = ItemType.ASSET_INFORMATION_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is AssetInformationItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is AssetInformationItem && this == other
            }
        }

        data class CloseAmountItem(
            @StringRes
            val labelTextRes: Int,
            val transactionSign: TransactionSign,
            val transactionAmount: BigInteger,
            val formattedTransactionAmount: String,
            val assetName: AssetName
        ) : StandardTransactionItem() {

            override val itemType: ItemType = ItemType.CLOSE_TO_AMOUNT_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is CloseAmountItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is CloseAmountItem && this == other
            }
        }

        sealed class AccountItem : StandardTransactionItem() {

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
                val accountIconDrawablePreview: AccountIconDrawablePreview
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

        data class DateItem(
            @StringRes
            val labelTextRes: Int,
            val date: String
        ) : StandardTransactionItem() {

            override val itemType: ItemType = ItemType.DATE_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is DateItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is DateItem && this == other
            }
        }

        data class RoundItem(
            @StringRes
            val labelTextRes: Int,
            val round: String
        ) : StandardTransactionItem() {

            override val itemType: ItemType = ItemType.ROUND_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is RoundItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is RoundItem && this == other
            }
        }

        data class TransactionIdItem(
            @StringRes
            val labelTextRes: Int,
            val transactionId: String
        ) : StandardTransactionItem() {

            override val itemType: ItemType = ItemType.TRANSACTION_ID_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is TransactionIdItem && labelTextRes == other.labelTextRes
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is TransactionIdItem && this == other
            }
        }

        sealed class StatusItem : StandardTransactionItem() {

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
    }

    sealed class BaseKeyRegItem : TransactionDetailItem() {

        data class OnlineKeyRegItem(
            val voteKey: String,
            val selectionKey: String,
            val stateProofKey: String,
            val validFirstRound: String,
            val validLastRound: String,
            val voteKeyDilution: String
        ) : BaseKeyRegItem() {

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is OnlineKeyRegItem && other.voteKey == voteKey
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is OnlineKeyRegItem && other == this
            }

            override val itemType: ItemType
                get() = ItemType.ONLINE_KEY_REG_ITEM
        }

        data class OfflineKeyRegItem(
            @StringRes val participationStatusResId: Int
        ) : BaseKeyRegItem() {

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is OfflineKeyRegItem && other.participationStatusResId == participationStatusResId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is OfflineKeyRegItem && other == this
            }

            override val itemType: ItemType
                get() = ItemType.OFFLINE_KEY_REG_ITEM
        }
    }
}
