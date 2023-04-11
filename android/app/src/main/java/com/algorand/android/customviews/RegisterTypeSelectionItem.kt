package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.getResourceIdOrThrow
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.databinding.CustomRegisterTypeSelectionBinding
import com.algorand.android.utils.BadgeDrawable
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding

class RegisterTypeSelectionItem @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomRegisterTypeSelectionBinding::inflate)

    init {
        setBackgroundResource(R.drawable.bg_standard_ripple)
        initAttributes(attrs)
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.RegisterTypeSelectionItem).use {
            val typeTitle = it.getText(R.styleable.RegisterTypeSelectionItem_typeSelectionTitleText)
            val badgeText = it.getText(R.styleable.RegisterTypeSelectionItem_typeSelectionTitleBadgeText)
            val isTypeBadgeVisible = it.getBoolean(
                R.styleable.RegisterTypeSelectionItem_typeSelectionTitleBadgeVisible,
                false
            )
            initTypeTitle(typeTitle, badgeText, isTypeBadgeVisible)

            val typeDescription = it.getText(R.styleable.RegisterTypeSelectionItem_typeSelectionDescriptionText)
            initTypeDescription(typeDescription)

            val typeIcon = it.getResourceIdOrThrow(R.styleable.RegisterTypeSelectionItem_typeSelectionIcon)
            initTypeIcon(typeIcon)
        }
    }

    private fun initTypeTitle(typeTitle: CharSequence, badgeText: CharSequence?, isTypeBadgeVisible: Boolean) {
        binding.titleTextView.apply {
            text = typeTitle
            if (isTypeBadgeVisible) {
                val badgeDrawable = BadgeDrawable.toDrawable(
                    context = context,
                    badgeText = badgeText.toString().uppercase(),
                    textColor = R.color.positive,
                    backgroundColor = R.color.positive_lighter
                )
                setDrawable(end = badgeDrawable)
            }
        }
    }

    private fun initTypeDescription(typeDescription: CharSequence) {
        binding.descriptionTextView.text = typeDescription
    }

    private fun initTypeIcon(typeIcon: Int) {
        binding.typeImageView.setImageResource(typeIcon)
    }
}
