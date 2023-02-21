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

package com.algorand.android.customviews.alertview.ui

import android.animation.Animator
import android.app.Dialog
import android.content.Context
import android.os.Bundle
import android.util.DisplayMetrics
import android.view.Gravity
import android.view.ViewGroup
import android.view.WindowManager
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.core.view.marginBottom
import androidx.core.view.marginTop
import androidx.core.view.updateLayoutParams
import com.algorand.android.databinding.CustomAlertViewBinding
import com.algorand.android.models.AlertMetadata
import com.algorand.android.models.NotificationMetadata
import com.algorand.android.models.NotificationType.ASSET_TRANSACTION_RECEIVED
import com.algorand.android.models.NotificationType.ASSET_TRANSACTION_SENT
import com.algorand.android.models.NotificationType.TRANSACTION_RECEIVED
import com.algorand.android.models.NotificationType.TRANSACTION_SENT
import com.algorand.android.utils.getDisplaySize
import com.algorand.android.utils.viewbinding.viewBinding

class CustomAlertDialog constructor(context: Context) : Dialog(context) {

    private val binding = viewBinding(CustomAlertViewBinding::inflate)

    private val toOriginalPositionListener = object : AlertViewAnimatorListener {
        override fun onAnimationStart(animation: Animator?) {
            if (!isShowing) show()
        }

        override fun onAnimationCancel(animation: Animator?) {
            binding.cardView.apply { y = -height.toFloat() + -marginBottom.toFloat() }
        }
    }

    private val fromOriginalPositionListener = object : AlertViewAnimatorListener {
        override fun onAnimationEnd(animation: Animator?) {
            hideAlertView()
        }

        override fun onAnimationCancel(animation: Animator?) {
            binding.cardView.apply { y = -height.toFloat() + -marginBottom.toFloat() }
        }
    }

    private var listener: Listener? = null

    @Volatile
    private var latestAlertMetadata: AlertMetadata? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(binding.root)
        initView()
        updateDialogWindow()
        updateDialogDecorView()
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    fun displayAlertView(alertMetadata: AlertMetadata) {
        with(alertMetadata) {
            latestAlertMetadata = this
            setCardView(backgroundColorRes)
            setAlertIconView(iconRes, iconTintRes)
            setTitleTextView(title, titleColorRes)
            setDescriptionTextView(description, descriptionColorRes)
        }
        moveAlertToOriginalPosition()
    }

    fun dismissCurrentAlertView() {
        moveAlertToAboveOfScreen()
    }

    private fun setCardView(@ColorRes backgroundColorRes: Int) {
        binding.cardView.apply {
            setCardBackgroundColor(context.getColor(backgroundColorRes))
        }
    }

    private fun setAlertIconView(@DrawableRes iconResId: Int?, @ColorRes iconTintResId: Int?) {
        with(binding.alertIcon) {
            isVisible = iconResId != null
            iconResId?.let(::setImageResource)
            if (iconTintResId != null) setColorFilter(context.getColor(iconTintResId)) else colorFilter = null
        }
    }

    private fun setTitleTextView(titleText: String?, @ColorRes textColor: Int) {
        with(binding.titleTextView) {
            isVisible = !titleText.isNullOrBlank()
            text = titleText
            setTextColor(context.getColor(textColor))
            if (titleText.isNullOrBlank()) moveDescriptionUp() else moveDescriptionDown()
        }
    }

    private fun setDescriptionTextView(descriptionText: String?, @ColorRes textColor: Int) {
        with(binding.descriptionTextView) {
            isVisible = !descriptionText.isNullOrBlank()
            text = descriptionText
            setTextColor(context.getColor(textColor))
        }
        if (descriptionText.isNullOrBlank()) {
            binding.horizontalGuideline.setGuidelinePercent(1.0F)
        }
    }

    private fun moveDescriptionUp() {
        with(binding) {
            horizontalGuideline.setGuidelinePercent(1.0F)
            descriptionTextView.updateLayoutParams<ConstraintLayout.LayoutParams> {
                topToBottom = ConstraintLayout.LayoutParams.UNSET
                bottomToBottom = ConstraintLayout.LayoutParams.UNSET
                topToTop = ConstraintLayout.LayoutParams.PARENT_ID
                bottomToTop = horizontalGuideline.id
            }
        }
    }

    private fun moveDescriptionDown() {
        with(binding) {
            horizontalGuideline.setGuidelinePercent(FIFTY_PERCENT_HORIZONTAL_GUIDELINE)
            descriptionTextView.updateLayoutParams<ConstraintLayout.LayoutParams> {
                topToTop = ConstraintLayout.LayoutParams.UNSET
                bottomToTop = ConstraintLayout.LayoutParams.UNSET
                topToBottom = titleTextView.id
                bottomToBottom = ConstraintLayout.LayoutParams.PARENT_ID
            }
        }
    }

    private fun moveAlertToOriginalPosition() {
        binding.cardView.run {
            animate().y(marginTop.toFloat())
                .setInterpolator(DecelerateInterpolator())
                .setListener(toOriginalPositionListener)
                .setDuration(ALERT_IN_ANIMATION_DURATION)
                .withLayer()
                .start()
        }
    }

    private fun moveAlertToAboveOfScreen() {
        binding.cardView.run {
            animate().y(-height.toFloat() + -marginBottom.toFloat())
                .setInterpolator(AccelerateInterpolator())
                .setListener(fromOriginalPositionListener)
                .setDuration(ALERT_OUT_ANIMATION_DURATION)
                .withLayer()
                .start()
        }
    }

    private fun initView() {
        binding.root.setOnClickListener { onAlertViewClick() }
    }

    private fun updateDialogDecorView() {
        window?.decorView?.apply {
            val displayMetrics = DisplayMetrics().apply { context.getDisplaySize() }
            minimumWidth = displayMetrics.widthPixels
        }
    }

    private fun updateDialogWindow() {
        window?.apply {
            attributes = attributes?.apply {
                gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
                flags = 0
                addFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE)
                width = ViewGroup.LayoutParams.MATCH_PARENT
                setBackgroundDrawable(null)
                setDimAmount(0f)
            }
        }
    }

    private fun onAlertViewClick() {
        useLatestAlertMetadata { alertMetadata ->
            if (alertMetadata is AlertMetadata.AlertNotification) {
                listener?.onTransactionAlertClick(
                    accountAddress = getAccountAddressFromTransactionAlertMetadata(alertMetadata.metadata),
                    assetId = alertMetadata.metadata.getAssetDescription().assetId
                )
            }
            listener?.onAlertViewCancelled()
            dismissCurrentAlertView()
        }
    }

    private fun hideAlertView() {
        listener?.onAlertViewHidden()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        latestAlertMetadata = null
    }

    private fun getAccountAddressFromTransactionAlertMetadata(metadata: NotificationMetadata): String {
        return when (metadata.getNotificationType()) {
            TRANSACTION_RECEIVED, ASSET_TRANSACTION_RECEIVED -> metadata.receiverPublicKey
            TRANSACTION_SENT, ASSET_TRANSACTION_SENT -> metadata.senderPublicKey
            else -> null
        }.orEmpty()
    }

    private fun useLatestAlertMetadata(block: (AlertMetadata) -> Unit) {
        synchronized(this) {
            latestAlertMetadata?.let(block)
        }
    }

    interface Listener {
        fun onTransactionAlertClick(accountAddress: String, assetId: Long)
        fun onAlertViewHidden()
        fun onAlertViewCancelled()
    }

    companion object {
        private const val ALERT_OUT_ANIMATION_DURATION = 600L
        private const val ALERT_IN_ANIMATION_DURATION = 800L
        private const val FIFTY_PERCENT_HORIZONTAL_GUIDELINE = 0.5F
    }
}
