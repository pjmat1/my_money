import React from 'react'
import { useDispatch, useSelector } from 'react-redux'

import { useGroupedAccounts } from 'hooks/useGroupedAccounts'
import Select, {
  MultiOption,
  SingleOption,
} from 'components/common/controls/MultiSelect'
import {
  setCurrentAccount,
  setCurrentSelectedAccounts,
} from 'stores/currentSlice'
import { Account } from 'types/models'
import { RootState } from 'stores/store'

type AccountFilterProps = {
  isMulti: boolean
  activeOnly?: boolean
}

const AccountFilter = (props: AccountFilterProps) => {
  const { isSuccess, groupedAccounts, activeGroupedAccounts, currentAccount } =
    useGroupedAccounts()
  const currentSelectedAccounts = useSelector(
    (state: RootState) => state.currentStore.currentSelectedAccounts,
  )
  const dispatch = useDispatch()

  const visibleGroupedAccounts = props.activeOnly
    ? activeGroupedAccounts
    : groupedAccounts

  const groupedOptions = visibleGroupedAccounts?.map((ga) => ({
    label: ga.accountType.name,
    options: ga.accounts,
  }))

  const onSelectAccount = (account: MultiOption | SingleOption | null) => {
    if (!account) {
      return
    }

    if (props.isMulti) {
      dispatch(setCurrentSelectedAccounts(account as Account[]))
    } else {
      dispatch(setCurrentAccount(account as Account))
    }
  }

  if (isSuccess && visibleGroupedAccounts && currentAccount) {
    return (
      <div className="account-filter">
        <label htmlFor="accountId" className="control-label">
          Accounts
        </label>
        <Select
          name="dateRangeId"
          value={props.isMulti ? currentSelectedAccounts : currentAccount}
          groupedOptions={groupedOptions}
          onChange={onSelectAccount}
          isMulti={props.isMulti}
        />
      </div>
    )
  }
  return <div />
}

export default AccountFilter
