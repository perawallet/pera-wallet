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

package com.algorand.android.customviews

import android.animation.Animator
import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import android.widget.FrameLayout
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.marginBottom
import androidx.core.view.marginTop
import androidx.core.view.updateLayoutParams
import androidx.lifecycle.LifecycleObserver
import com.algorand.android.databinding.CustomAlertViewBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AlertMetadata
import com.algorand.android.models.NotificationMetadata
import com.algorand.android.models.NotificationType
import com.algorand.android.models.User
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.setupAlgoReceivedMessage
import com.algorand.android.utils.setupAlgoSentMessage
import com.algorand.android.utils.setupAssetSupportSuccessMessage
import com.algorand.android.utils.setupFailedMessage
import com.algorand.android.utils.viewbinding.viewBinding
import java.util.ArrayDeque
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class AlertView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs), LifecycleObserver {

    private val binding = viewBinding(CustomAlertViewBinding::inflate)

    private var listener: AlertViewListener? = null

    private var isAlertShown = false

    private var scope: CoroutineScope? = null
    private var timerJob: Job? = null

    // Using coroutines instead of Handler/Runnable for cleaner implementation
    fun setScope(lifecycleScope: CoroutineScope) {
        scope = lifecycleScope
    }

    private val alertQueue = ArrayDeque<AlertMetadata>()

    // TODO find a better way to retrieve contacts/accounts name and remove these
    var contacts: List<User>? = null
    var accounts: List<Account>? = null

    init {
        initView()
    }

    private fun initView() {
        binding.cardView.setOnClickListener { onAlertClick() }
    }

    private fun onAlertClick() {
        val alertMessage = alertQueue.firstOrNull() ?: return
        when (alertMessage) {
            is AlertMetadata.AlertNotification -> {
                val publicKeyToActivate = when (alertMessage.metadata.getNotificationType()) {
                    NotificationType.TRANSACTION_RECEIVED, NotificationType.ASSET_TRANSACTION_RECEIVED -> {
                        alertMessage.metadata.receiverPublicKey
                    }
                    NotificationType.TRANSACTION_SENT, NotificationType.ASSET_TRANSACTION_SENT -> {
                        alertMessage.metadata.senderPublicKey
                    }
                    else -> null
                }

                listener?.onAlertNotificationClick(
                    publicKeyToActivate,
                    alertMessage.metadata.getAssetDescription().assetId
                )
            }
            // Implement different click behaviors here
            // Remember to add methods to listener if you need to pass different data

            else -> {
                timerJob?.cancel()
                dismissCurrentAlert()
            }
        }
    }

    fun setListener(listener: AlertViewListener) {
        this.listener = listener
    }

    fun addAlert(alertMetadata: AlertMetadata) {
        alertQueue.add(alertMetadata)
        if (isAlertShown.not()) {
            showNextAlert()
        }
    }

    fun addAlertError(
        title: String,
        description: String,
        tag: String? = null
    ) {
        addAlert(
            AlertMetadata.AlertError(
                title = title,
                description = description,
                tag = tag
            )
        )
    }

    fun addAlertSuccess(
        title: String,
        description: String? = null,
        tag: String? = null
    ) {
        addAlert(
            AlertMetadata.AlertSuccess(
                title = title,
                description = description,
                tag = tag
            )
        )
    }

    fun addAlertNotification(
        notificationMetadata: NotificationMetadata,
        title: String? = null,
        description: String? = null,
        tag: String? = null
    ) {
        addAlert(
            AlertMetadata.AlertNotification(
                title = title ?: getTitleForAlertNotification(notificationMetadata),
                description = description,
                metadata = notificationMetadata,
                tag = tag
            )
        )
    }

    fun removeAlertsWithTag(tag: String) {
        if (alertQueue.size > 0) {
            scope?.launch {
                timerJob?.cancelAndJoin()
                alertQueue.removeIf {
                    it.tag.equals(tag)
                }
                if (alertQueue.size == 0) {
                    withContext(Dispatchers.Main) {
                        moveAlertToAboveOfScreen()
                    }
                } else {
                    showNextAlert()
                }
            }
        }
    }

    private fun showNextAlert() {
        if (alertQueue.size > 0) {
            isAlertShown = true
            binding.cardView.show()

            with(alertQueue.first) {
                // Setting up the view with the data from the AlertMetadata class
                binding.cardView.setCardBackgroundColor(context.getColor(backgroundColorRes))
                iconRes?.let { icon ->
                    binding.alertIcon.visibility = View.VISIBLE
                    binding.alertIcon.setImageResource(icon)
                    iconTintRes?.let { tint ->
                        binding.alertIcon.setColorFilter(context.getColor(tint))
                    } ?: run { binding.alertIcon.colorFilter = null }
                } ?: run { binding.alertIcon.visibility = View.INVISIBLE }

                title?.let {
                    binding.titleTextView.visibility = View.VISIBLE
                    binding.titleTextView.text = title
                    binding.titleTextView.setTextColor(context.getColor(titleColorRes))
                    moveDescriptionDown()
                } ?: run {
                    binding.titleTextView.visibility = View.GONE
                    moveDescriptionUp()
                }

                description?.let {
                    binding.descriptionTextView.visibility = View.VISIBLE
                    binding.descriptionTextView.text = description
                    binding.descriptionTextView.setTextColor(context.getColor(descriptionColorRes))
                } ?: run {
                    binding.descriptionTextView.visibility = View.GONE
                    binding.horizontalGuideline.setGuidelinePercent(1.0F)
                }
                moveAlertToOriginalPosition()
            }

            startAlertMaxDurationTimeout()
        } else {
            isAlertShown = false
            binding.cardView.hide()
        }
    }

    private fun moveDescriptionUp() {
        binding.horizontalGuideline.setGuidelinePercent(1.0F)
        binding.descriptionTextView.updateLayoutParams<ConstraintLayout.LayoutParams> {
            topToBottom = ConstraintLayout.LayoutParams.UNSET
            bottomToBottom = ConstraintLayout.LayoutParams.UNSET
            topToTop = ConstraintLayout.LayoutParams.PARENT_ID
            bottomToTop = binding.horizontalGuideline.id
        }
    }

    private fun moveDescriptionDown() {
        binding.horizontalGuideline.setGuidelinePercent(0.5F)
        binding.descriptionTextView.updateLayoutParams<ConstraintLayout.LayoutParams> {
            topToTop = ConstraintLayout.LayoutParams.UNSET
            bottomToTop = ConstraintLayout.LayoutParams.UNSET
            topToBottom = binding.titleTextView.id
            bottomToBottom = ConstraintLayout.LayoutParams.PARENT_ID
        }
    }

    private fun getTitleForAlertNotification(notificationMetadata: NotificationMetadata): String {
        with(notificationMetadata) {
            val senderName = getAccountNameIfPossible(senderPublicKey)
            val receiverName = getAccountNameIfPossible(receiverPublicKey)

            return when (getNotificationType()) {
                NotificationType.TRANSACTION_RECEIVED, NotificationType.ASSET_TRANSACTION_RECEIVED -> {
                    val assetDescription = getAssetDescription()
                    val formattedAmount = safeAmount.formatAmount(
                        assetDescription.decimals ?: ALGO_DECIMALS
                    )
                    context?.setupAlgoReceivedMessage(
                        formattedAmount,
                        senderName,
                        receiverName,
                        assetDescription
                    )
                }
                NotificationType.TRANSACTION_SENT, NotificationType.ASSET_TRANSACTION_SENT -> {
                    val assetDescription = getAssetDescription()
                    val formattedAmount = safeAmount.formatAmount(
                        assetDescription.decimals ?: ALGO_DECIMALS
                    )
                    context?.setupAlgoSentMessage(
                        formattedAmount,
                        senderName,
                        receiverName,
                        assetDescription
                    )
                }
                NotificationType.TRANSACTION_FAILED, NotificationType.ASSET_TRANSACTION_FAILED -> {
                    val assetDescription = getAssetDescription()
                    val formattedAmount = safeAmount.formatAmount(
                        assetDescription.decimals ?: ALGO_DECIMALS
                    )
                    context?.setupFailedMessage(
                        formattedAmount,
                        senderName,
                        receiverName,
                        assetDescription
                    )
                }
                NotificationType.ASSET_SUPPORT_SUCCESS -> {
                    context?.setupAssetSupportSuccessMessage(senderPublicKey, getAssetDescription())
                }
                NotificationType.UNKNOWN, NotificationType.BROADCAST -> alertMessage
                else -> ""
            }?.toString() ?: ""
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

    private fun dismissCurrentAlert() {
        if (alertQueue.size > 0) {
            alertQueue.removeFirst()
            moveAlertToAboveOfScreen()
        }
    }

    private fun startAlertMaxDurationTimeout() {
        timerJob = scope?.launch {
            delay(MAX_SHOWN_DURATION)
            dismissCurrentAlert()
        }
    }

    private fun moveAlertToOriginalPosition() {
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
                .setDuration(ALERT_IN_ANIMATION_DURATION)
                .withLayer()
                .start()
        }
    }

    private fun moveAlertToAboveOfScreen() {
        binding.cardView.run {
            val finishPointY = -height.toFloat() + -marginBottom.toFloat()
            animate()
                .y(finishPointY)
                .setInterpolator(AccelerateInterpolator())
                .setDuration(ALERT_OUT_ANIMATION_DURATION)
                .withLayer()
                .setListener(object : Animator.AnimatorListener {
                    override fun onAnimationRepeat(animation: Animator?) {
                        // nothing to do
                    }

                    override fun onAnimationEnd(animation: Animator?) {
                        showNextAlert()
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

    interface AlertViewListener {
        fun onAlertNotificationClick(publicKeyToActivate: String?, assetIdToActivate: Long?)
    }

    companion object {
        private const val ALERT_OUT_ANIMATION_DURATION = 600L
        private const val ALERT_IN_ANIMATION_DURATION = 800L
        private const val MAX_SHOWN_DURATION = 3000L
    }
}
