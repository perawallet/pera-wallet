package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.getResourceIdOrThrow
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.databinding.CustomRegisterTypeSelectionBinding
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
            val typeIcon = it.getResourceIdOrThrow(R.styleable.RegisterTypeSelectionItem_typeSelectionIcon)
            binding.typeImageView.setImageResource(typeIcon)
            binding.titleTextView.text = it.getText(R.styleable.RegisterTypeSelectionItem_typeSelectionTitleText)
            binding.descriptionTextView.text =
                it.getText(R.styleable.RegisterTypeSelectionItem_typeSelectionDescriptionText)
        }
    }
}
