package com.algorand.android.ui.settings

import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetRateExperienceBinding
import com.algorand.android.utils.openApplicationPageOnStore
import com.algorand.android.utils.viewbinding.viewBinding

class RateExperienceBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_rate_experience) {

    private val binding by viewBinding(BottomSheetRateExperienceBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.likeButton.setOnClickListener { onLikeClick() }
        binding.dislikeButton.setOnClickListener { onDislikeClick() }
    }

    private fun onLikeClick() {
        navBack()
        context?.openApplicationPageOnStore()
    }

    private fun onDislikeClick() {
        navBack()
    }
}
