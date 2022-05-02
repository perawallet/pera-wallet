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

package com.algorand.android.models

import android.os.Parcelable
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.utils.ALGOS_SHORT_NAME
import java.math.BigInteger
import java.time.ZonedDateTime
import kotlinx.parcelize.Parcelize

sealed class BaseTransactionItem : RecyclerListItem, Parcelable {

    @Parcelize
    data class StringTitleItem(val title: String) : BaseTransactionItem(), Parcelable {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is StringTitleItem && title == other.title
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is StringTitleItem && other == this
        }
    }

    @Parcelize
    data class ResourceTitleItem(@StringRes val stringRes: Int) : BaseTransactionItem(), Parcelable {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is ResourceTitleItem && stringRes == other.stringRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is ResourceTitleItem && other == this
        }
    }

    sealed class TransactionItem : BaseTransactionItem(), Parcelable {

        abstract val assetId: Long?
        abstract val id: String?
        abstract val signature: String?
        abstract val accountPublicKey: String
        abstract val otherPublicKey: String?
        abstract val amount: BigInteger?
        abstract val transactionSymbol: TransactionSymbol?
        abstract val transactionItemType: TransactionItemType
        abstract val isAlgorand: Boolean
        abstract var transactionTargetUser: TransactionTargetUser?
        abstract val zonedDateTime: ZonedDateTime?
        abstract val date: String
        abstract val fee: Long?
        abstract val noteInB64: String?
        abstract val decimals: Int
        abstract val formattedFullAmount: String

        abstract val transactionName: TransactionName

        open val closeToAddress: String? = null
        open val closeToAmount: BigInteger? = null
        open val round: Long? = null
        open val rewardAmount: Long? = null
        open val assetShortName: String? = null

        abstract fun isSameTransaction(other: RecyclerListItem): Boolean

        @Parcelize
        data class Transaction(
            override val assetId: Long?,
            override val id: String?,
            override val signature: String?,
            override val accountPublicKey: String,
            override val otherPublicKey: String?,
            override val amount: BigInteger?,
            override val transactionSymbol: TransactionSymbol?,
            override val transactionItemType: TransactionItemType = TransactionItemType.TRANSFER,
            override val isAlgorand: Boolean,
            override var transactionTargetUser: TransactionTargetUser?,
            override val zonedDateTime: ZonedDateTime?,
            override val date: String,
            override val fee: Long?,
            override val noteInB64: String?,
            override val decimals: Int,
            override val formattedFullAmount: String,
            override val closeToAmount: BigInteger?,
            override val closeToAddress: String?,
            override val round: Long?,
            override val rewardAmount: Long?,
            override val assetShortName: String?,
            override val transactionName: TransactionName
        ) : TransactionItem(), Parcelable {

            override fun isSameTransaction(other: RecyclerListItem): Boolean {
                val transaction = other as? Transaction ?: return false
                return signature != null && signature == transaction.signature
            }

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return isSameTransaction(other)
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is Transaction && this == other
            }
        }

        @Parcelize
        data class Reward(
            val amountInMicroAlgos: Long,
            override val assetId: Long?,
            override val id: String?,
            override val signature: String?,
            override val accountPublicKey: String,
            override val otherPublicKey: String?,
            override val amount: BigInteger?,
            override val transactionSymbol: TransactionSymbol? = TransactionSymbol.POSITIVE,
            override val transactionItemType: TransactionItemType = TransactionItemType.REWARD,
            override val isAlgorand: Boolean,
            override var transactionTargetUser: TransactionTargetUser?,
            override val zonedDateTime: ZonedDateTime?,
            override val date: String,
            override val fee: Long?,
            override val noteInB64: String?,
            override val decimals: Int,
            override val formattedFullAmount: String,
            override val rewardAmount: Long?,
            override val transactionName: TransactionName = TransactionName.REWARD,
            override val assetShortName: String? = ALGOS_SHORT_NAME
        ) : TransactionItem(), Parcelable {

            override fun isSameTransaction(other: RecyclerListItem): Boolean {
                return this == (other as? Reward ?: false)
            }

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return isSameTransaction(other)
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is Reward && this == other
            }
        }

        @Parcelize
        data class Pending(
            override val assetId: Long?,
            override val id: String?,
            override val signature: String?,
            override val accountPublicKey: String,
            override val otherPublicKey: String?,
            override val amount: BigInteger?,
            override val transactionSymbol: TransactionSymbol?,
            override val transactionItemType: TransactionItemType = TransactionItemType.PENDING,
            override val isAlgorand: Boolean,
            override var transactionTargetUser: TransactionTargetUser?,
            override val zonedDateTime: ZonedDateTime?,
            override val date: String,
            override val fee: Long?,
            override val noteInB64: String?,
            override val decimals: Int,
            override val formattedFullAmount: String,
            override val closeToAmount: BigInteger?,
            override val closeToAddress: String?,
            override val round: Long?,
            override val rewardAmount: Long?,
            override val assetShortName: String?,
            override val transactionName: TransactionName
        ) : TransactionItem(), Parcelable {

            override fun isSameTransaction(other: RecyclerListItem): Boolean {
                val transaction = other as? Pending ?: return false
                return signature != null && signature == transaction.signature
            }

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return isSameTransaction(other)
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is Pending && this == other
            }
        }

        @Parcelize
        data class Fee(
            override val assetId: Long?,
            override val id: String?,
            override val signature: String?,
            override val accountPublicKey: String,
            override val otherPublicKey: String?,
            override val amount: BigInteger? = BigInteger.ZERO,
            override val transactionSymbol: TransactionSymbol? = TransactionSymbol.NEGATIVE,
            override val transactionItemType: TransactionItemType,
            override val isAlgorand: Boolean,
            override val zonedDateTime: ZonedDateTime?,
            override val date: String,
            override val fee: Long?,
            override val noteInB64: String?,
            override val decimals: Int,
            override var transactionTargetUser: TransactionTargetUser?,
            override val formattedFullAmount: String,
            override val closeToAmount: BigInteger?,
            override val closeToAddress: String?,
            override val round: Long?,
            override val rewardAmount: Long?,
            override val assetShortName: String?,
            override val transactionName: TransactionName
        ) : TransactionItem(), Parcelable {

            override fun isSameTransaction(other: RecyclerListItem): Boolean {
                val transaction = other as? Fee ?: return false
                return signature != null && signature == transaction.signature
            }

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return isSameTransaction(other)
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is Fee && this == other
            }
        }
    }

    enum class TransactionName(@StringRes val stringRes: Int) {
        SEND(R.string.send),
        RECEIVE(R.string.receive),
        REWARD(R.string.reward),
        ASSET_ADDITION(R.string.add_asset_fee),
        ASSET_REMOVAL(R.string.remove_asset_fee),
        REKEY_ACCOUNT(R.string.rekey_fee),
        UNDEFINED(R.string.undefined)
    }
}
