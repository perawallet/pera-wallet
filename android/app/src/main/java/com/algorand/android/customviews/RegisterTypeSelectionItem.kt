package com.algorand.android.customviews

import android.content.Context
import android.content.res.TypedArray
import android.util.AttributeSet
import android.widget.ImageView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.getResourceIdOrThrow
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.databinding.CustomRegisterTypeSelectionBinding
import com.algorand.android.utils.NewBadgeDrawable
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
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
        with(binding) {
            context.obtainStyledAttributes(attrs, R.styleable.RegisterTypeSelectionItem).use {
                val typeIcon = it.getResourceIdOrThrow(R.styleable.RegisterTypeSelectionItem_typeSelectionIcon)
                typeImageView.setImageResource(typeIcon)

                titleTextView.text = it.getText(R.styleable.RegisterTypeSelectionItem_typeSelectionTitleText)

                descriptionTextView.text =
                    it.getText(R.styleable.RegisterTypeSelectionItem_typeSelectionDescriptionText)

                initTitleTextViewBadge(it, titleTextViewBadge)
            }
        }
    }

    private fun initTitleTextViewBadge(typedAttributes: TypedArray, titleTextViewBadge: ImageView) {
        val titleTextViewBadgeVisible = typedAttributes
            .getBoolean(R.styleable.RegisterTypeSelectionItem_typeSelectionTitleBadgeVisible, false)
        if (titleTextViewBadgeVisible) {
            titleTextViewBadge.show()
            val iconText = typedAttributes.getText(R.styleable.RegisterTypeSelectionItem_typeSelectionTitleBadgeText)
            titleTextViewBadge.setImageDrawable(
                NewBadgeDrawable.toDrawable(context, iconText.toString().uppercase())
            )
        } else {
            titleTextViewBadge.hide()
        }
    }
}
