package com.algorand.android.modules.accountdetail.assets.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemRequiredMinimumBalanceBinding
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem
import com.algorand.android.models.BaseViewHolder

class RequiredMinimumBalanceItemViewHolder(
    private val binding: ItemRequiredMinimumBalanceBinding,
    private val listener: RequiredMinimumBalanceListener
) : BaseViewHolder<AccountDetailAssetsItem>(binding.root) {

    override fun bind(item: AccountDetailAssetsItem) {
        if (item !is AccountDetailAssetsItem.RequiredMinimumBalanceItem) return
        binding.requiredMinBalanceTextView.apply {
            text = resources.getString(
                R.string.min_balance,
                item.formattedRequiredMinimumBalance
            )
            setOnClickListener { listener.onInfoButtonClick() }
        }
    }

    fun interface RequiredMinimumBalanceListener {
        fun onInfoButtonClick()
    }

    companion object {
        fun create(parent: ViewGroup, listener: RequiredMinimumBalanceListener): RequiredMinimumBalanceItemViewHolder {
            val binding = ItemRequiredMinimumBalanceBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return RequiredMinimumBalanceItemViewHolder(binding, listener)
        }
    }
}
