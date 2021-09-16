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

package com.algorand.android.customviews

import android.animation.Animator
import android.content.Context
import android.os.Handler
import android.util.AttributeSet
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import android.widget.FrameLayout
import androidx.core.view.marginBottom
import androidx.core.view.marginTop
import com.algorand.android.databinding.CustomForegroundNotificationBinding
import com.algorand.android.models.Account
import com.algorand.android.models.NotificationMetadata
import com.algorand.android.models.NotificationType
import com.algorand.android.models.User
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.setupAlgoReceivedMessage
import com.algorand.android.utils.setupAlgoSentMessage
import com.algorand.android.utils.setupAssetSupportSuccessMessage
import com.algorand.android.utils.setupFailedMessage
import com.algorand.android.utils.viewbinding.viewBinding
import java.util.ArrayDeque

class ForegroundNotificationView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {

    private val binding = viewBinding(CustomForegroundNotificationBinding::inflate)

    private var listener: ForegroundNotificationViewListener? = null

    private var isNotificationShown = false

    private val maxDurationShownHandler: Handler by lazy {
        Handler()
    }

    private val privateMaxDurationRunnable = Runnable {
        dismissCurrentNotification()
    }

    private val notificationMessageQueue = ArrayDeque<NotificationMetadata>()

    var contacts: List<User>? = null
    var accounts: List<Account>? = null

    init {
        initView()
    }

    private fun initView() {
        binding.cardView.setOnClickListener { onNotificationClick() }
    }

    private fun onNotificationClick() {
        val notificationMessage = notificationMessageQueue.firstOrNull() ?: return
        val publicKeyToActivate = when (notificationMessage.getNotificationType()) {
            NotificationType.TRANSACTION_RECEIVED, NotificationType.ASSET_TRANSACTION_RECEIVED -> {
                notificationMessage.receiverPublicKey
            }
            NotificationType.TRANSACTION_SENT, NotificationType.ASSET_TRANSACTION_SENT -> {
                notificationMessage.senderPublicKey
            }
            else -> null
        }

        listener?.onNotificationClick(publicKeyToActivate, notificationMessage.getAssetDescription().assetId)
    }

    fun setListener(listener: ForegroundNotificationViewListener) {
        this.listener = listener
    }

    fun addNotification(notificationMetadata: NotificationMetadata) {
        notificationMessageQueue.add(notificationMetadata)

        if (isNotificationShown.not()) {
            showNextNotification()
        }
    }

    private fun showNextNotification() {
        if (notificationMessageQueue.size > 0) {
            isNotificationShown = true

            with(notificationMessageQueue.first) {
                val senderName = getAccountNameIfPossible(senderPublicKey)
                val receiverName = getAccountNameIfPossible(receiverPublicKey)

                binding.textView.text = when (getNotificationType()) {
                    NotificationType.TRANSACTION_RECEIVED, NotificationType.ASSET_TRANSACTION_RECEIVED -> {
                        val assetDescription = getAssetDescription()
                        val formattedAmount = safeAmount.formatAmount(assetDescription.decimals ?: ALGO_DECIMALS)
                        context?.setupAlgoReceivedMessage(formattedAmount, senderName, receiverName, assetDescription)
                    }
                    NotificationType.TRANSACTION_SENT, NotificationType.ASSET_TRANSACTION_SENT -> {
                        val assetDescription = getAssetDescription()
                        val formattedAmount = safeAmount.formatAmount(assetDescription.decimals ?: ALGO_DECIMALS)
                        context?.setupAlgoSentMessage(formattedAmount, senderName, receiverName, assetDescription)
                    }
                    NotificationType.TRANSACTION_FAILED, NotificationType.ASSET_TRANSACTION_FAILED -> {
                        val assetDescription = getAssetDescription()
                        val formattedAmount = safeAmount.formatAmount(assetDescription.decimals ?: ALGO_DECIMALS)
                        context?.setupFailedMessage(formattedAmount, senderName, receiverName, assetDescription)
                    }
                    NotificationType.ASSET_SUPPORT_SUCCESS -> {
                        context?.setupAssetSupportSuccessMessage(senderPublicKey, getAssetDescription())
                    }
                    NotificationType.UNKNOWN, NotificationType.BROADCAST -> alertMessage
                    else -> ""
                }

                moveNotificationToOriginalPosition()
            }

            startNotificationMaxDurationShownHandler()
        } else {
            isNotificationShown = false
        }
    }

    private fun getAccountNameIfPossible(publicAddress: String?): String {
        if (publicAddress.isNullOrEmpty()) {
            // there's no way to get public address null unless backend error.
            // So, empty string can be assigned
            return ""
        }
        val nameFromAccountList = accounts?.firstOrNull { account -> account.address == publicAddress }?.name
        return nameFromAccountList ?: ((contacts?.firstOrNull { it.publicKey == publicAddress })?.name ?: publicAddress)
    }

    private fun dismissCurrentNotification() {
        if (notificationMessageQueue.size > 0) {
            maxDurationShownHandler.removeCallbacksAndMessages(null)

            notificationMessageQueue.removeFirst()

            moveNotificationToAboveOfScreen()
        }
    }

    private fun startNotificationMaxDurationShownHandler() {
        maxDurationShownHandler.postDelayed(privateMaxDurationRunnable, MAX_SHOWN_DURATION)
    }

    private fun moveNotificationToOriginalPosition() {
        binding.cardView.run {
            val cancelYPosition = -height.toFloat() + -marginBottom.toFloat()
            animate()
                .y(binding.cardView.marginTop.toFloat())
                .setInterpolator(DecelerateInterpolator())
                .setListener(object : Animator.AnimatorListener {
                    override fun onAnimationRepeat(animation: Animator?) {
                        // nothing to do
                    }

                    override fun onAnimationEnd(animation: Animator?) {
                        // nothing to do
                    }

                    override fun onAnimationCancel(animation: Animator?) {
                        binding.cardView.y = cancelYPosition
                    }

                    override fun onAnimationStart(animation: Animator?) {
                        // nothing to do
                    }
                })
                .setDuration(NOTIFICATION_IN_ANIMATION_DURATION)
                .withLayer()
                .start()
        }
    }

    private fun moveNotificationToAboveOfScreen() {
        binding.cardView.run {
            val finishPointY = -height.toFloat() + -marginBottom.toFloat()
            animate()
                .y(finishPointY)
                .setInterpolator(AccelerateInterpolator())
                .setDuration(OUT_ANIMATION_DURATION)
                .withLayer()
                .setListener(object : Animator.AnimatorListener {
                    override fun onAnimationRepeat(animation: Animator?) {
                        // nothing to do
                    }

                    override fun onAnimationEnd(animation: Animator?) {
                        Handler().postDelayed({ showNextNotification() }, NEXT_NOTIFICATION_DELAY)
                    }

                    override fun onAnimationCancel(animation: Animator?) {
                        binding.cardView.y = finishPointY
                    }

                    override fun onAnimationStart(animation: Animator?) {
                        // nothing to do
                    }
                })
                .start()
        }
    }

    interface ForegroundNotificationViewListener {
        fun onNotificationClick(publicKeyToActivate: String?, assetIdToActivate: Long?)
    }

    companion object {
        private const val OUT_ANIMATION_DURATION = 600L
        private const val NOTIFICATION_IN_ANIMATION_DURATION = 800L
        private const val MAX_SHOWN_DURATION = 3000L
        private const val NEXT_NOTIFICATION_DELAY = 500L
    }
}
