import React, { useState } from 'react'
import { useDispatch } from 'react-redux'
import { Button } from 'react-bootstrap'

import PageHeader from '../common/PageHeader'
import { PatternTable } from './PatternTable'
import { PatternModal } from './PatternModal'
import { showFormModal } from 'stores/formSlice'
import { useGetPatternsQuery } from 'stores/patternApi'
import { useGroupedCategories } from 'hooks/useGroupedCategories'
import { ModelType } from 'types/models'

import '../../stylesheets/common.scss'
import '../../stylesheets/patterns.scss'

export const PatternList = () => {
  const { data: patterns, isLoading } = useGetPatternsQuery()
  const { groupedCategories, isSuccess: isSuccessGC } = useGroupedCategories()
  const dispatch = useDispatch()
  const [searchText, setSearchText] = useState('')

  const filteredPatterns = patterns?.filter((pattern) => {
    const search = searchText.toLowerCase()
    return (
      pattern.matchText.toLowerCase().includes(search) ||
      pattern.notes?.toLowerCase().includes(search)
    )
  })

  const newPattern = () => {
    dispatch(
      showFormModal({
        modelType: ModelType.Pattern,
        model: {},
        allowDelete: false,
      }),
    )
  }

  return (
    <div>
      <PageHeader title="my patterns" isLoading={isLoading}>
        <Button onClick={newPattern}>
          <i className="fas fa-plus" /> New
        </Button>
      </PageHeader>
      <div className="pattern-list">
        <input
          className="form-control pattern-search"
          type="text"
          placeholder="Search patterns..."
          aria-label="Search patterns"
          value={searchText}
          onChange={(event) => setSearchText(event.currentTarget.value)}
        />
        {filteredPatterns && groupedCategories && isSuccessGC && (
          <PatternTable
            patterns={filteredPatterns}
            groupedCategories={groupedCategories}
          />
        )}
      </div>
      {groupedCategories && isSuccessGC && (
        <PatternModal groupedCategories={groupedCategories} />
      )}
    </div>
  )
}

export default PatternList
