package com.algorand.android.modules.transactionhistory.domain.model

import androidx.annotation.StringRes
import java.math.BigInteger
import java.time.ZonedDateTime

sealed class BaseTransaction {

    data class TransactionDateTitle(val title: String) : BaseTransaction()

    data class PendingTransactionTitle(@StringRes val stringRes: Int) : BaseTransaction()

    sealed class Transaction : BaseTransaction() {

        abstract val id: String?
        abstract val signature: String?
        abstract val senderAddress: String?
        abstract val receiverAddress: String?
        abstract val zonedDateTime: ZonedDateTime?
        abstract val isPending: Boolean

        sealed class Pay : Transaction() {

            abstract val amount: BigInteger

            data class Send(
                override val id: String?,
                override val signature: String?,
                override val senderAddress: String?,
                override val receiverAddress: String?,
                override val zonedDateTime: ZonedDateTime?,
                override val isPending: Boolean,
                override val amount: BigInteger
            ) : Pay()

            data class Receive(
                override val id: String?,
                override val signature: String?,
                override val senderAddress: String?,
                override val receiverAddress: String?,
                override val zonedDateTime: ZonedDateTime?,
                override val isPending: Boolean,
                override val amount: BigInteger
            ) : Pay()

            data class Self(
                override val id: String?,
                override val signature: String?,
                override val senderAddress: String?,
                override val receiverAddress: String?,
                override val zonedDateTime: ZonedDateTime?,
                override val isPending: Boolean,
                override val amount: BigInteger
            ) : Pay()
        }

        sealed class AssetTransfer : Transaction() {

            abstract val assetId: Long
            abstract val amount: BigInteger

            data class Send(
                override val id: String?,
                override val signature: String?,
                override val senderAddress: String?,
                override val receiverAddress: String?,
                override val zonedDateTime: ZonedDateTime?,
                override val isPending: Boolean,
                override val amount: BigInteger,
                override val assetId: Long
            ) : AssetTransfer()

            sealed class BaseReceive : AssetTransfer() {

                data class Receive(
                    override val id: String?,
                    override val signature: String?,
                    override val senderAddress: String?,
                    override val receiverAddress: String?,
                    override val zonedDateTime: ZonedDateTime?,
                    override val isPending: Boolean,
                    override val amount: BigInteger,
                    override val assetId: Long
                ) : BaseReceive()

                data class ReceiveOptOut(
                    override val id: String?,
                    override val signature: String?,
                    override val senderAddress: String?,
                    override val receiverAddress: String?,
                    override val zonedDateTime: ZonedDateTime?,
                    override val isPending: Boolean,
                    override val amount: BigInteger,
                    override val assetId: Long
                ) : BaseReceive()
            }

            data class OptOut(
                override val id: String?,
                override val signature: String?,
                override val senderAddress: String?,
                override val receiverAddress: String?,
                override val zonedDateTime: ZonedDateTime?,
                override val isPending: Boolean,
                override val assetId: Long,
                override val amount: BigInteger,
                val closeToAddress: String
            ) : AssetTransfer()

            sealed class BaseSelf : AssetTransfer() {
                data class Self(
                    override val id: String?,
                    override val signature: String?,
                    override val senderAddress: String?,
                    override val receiverAddress: String?,
                    override val zonedDateTime: ZonedDateTime?,
                    override val isPending: Boolean,
                    override val assetId: Long,
                    override val amount: BigInteger
                ) : BaseSelf()

                data class SelfOptIn(
                    override val id: String?,
                    override val signature: String?,
                    override val senderAddress: String?,
                    override val receiverAddress: String?,
                    override val zonedDateTime: ZonedDateTime?,
                    override val isPending: Boolean,
                    override val assetId: Long,
                    override val amount: BigInteger
                ) : BaseSelf()
            }
        }

        data class AssetConfiguration(
            override val id: String?,
            override val signature: String?,
            override val senderAddress: String?,
            override val receiverAddress: String?,
            override val zonedDateTime: ZonedDateTime?,
            override val isPending: Boolean,
            val assetId: Long?
        ) : Transaction()

        data class ApplicationCall(
            override val id: String?,
            override val signature: String?,
            override val senderAddress: String?,
            override val receiverAddress: String?,
            override val zonedDateTime: ZonedDateTime?,
            override val isPending: Boolean,
            val applicationId: Long?,
            val innerTransactionCount: Int,
            val foreignAssetIds: List<Long>?
        ) : Transaction()

        data class Undefined(
            override val id: String? = null,
            override val signature: String? = null,
            override val senderAddress: String?,
            override val receiverAddress: String?,
            override val zonedDateTime: ZonedDateTime? = null,
            override val isPending: Boolean = false,
        ) : Transaction()
    }
}
