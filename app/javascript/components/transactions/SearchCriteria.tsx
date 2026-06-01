import React from 'react'
import { useDispatch, useSelector } from 'react-redux'

import CommonSearchCriteria, {
  ACCOUNT_FILTER,
  DATE_RANGE_FILTER,
} from '../common/criteria/SearchCriteria'
import DescriptionFilter from '../common/DescriptionFilter'
import { RootState } from 'stores/store'
import { setSearchDescription, toggleShowMore } from 'stores/transactionSlice'

import '../../stylesheets/transaction.scss'

const SearchCriteria = () => {
  const dispatch = useDispatch()
  const { showMoreOptions, searchDescription } = useSelector(
    (state: RootState) => state.transactionStore,
  )

  const onDescriptionChange = (description?: string) => {
    dispatch(setSearchDescription(description))
  }

  const onToggleMoreOrLess = () => {
    dispatch(toggleShowMore())
  }

  const renderMoreOptions = () => {
    return (
      <div className="more-options">
        <div onClick={onToggleMoreOrLess} className="more-or-less click-me">
          {renderMoreOrLess()}
        </div>
        {renderDescriptionFilter()}
      </div>
    )
  }

  const renderMoreOrLess = () => {
    if (showMoreOptions) {
      return (
        <span>
          less options <i className="fas fa-caret-up" />
        </span>
      )
    }
    return (
      <span>
        more options <i className="fas fa-caret-down" />
      </span>
    )
  }

  const renderDescriptionFilter = () => {
    if (showMoreOptions) {
      return (
        <DescriptionFilter
          description={searchDescription}
          onChange={onDescriptionChange}
        />
      )
    }

    return <div></div>
  }

  return (
    <React.Fragment>
      <CommonSearchCriteria
        filters={[
          { name: ACCOUNT_FILTER, options: { multiple: false, activeOnly: true } },
          { name: DATE_RANGE_FILTER },
        ]}
      />
      {renderMoreOptions()}
    </React.Fragment>
  )
}

export default SearchCriteria
