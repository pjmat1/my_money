import { PatternRequest, PatternResponse } from 'types/api'
import { Pattern } from 'types/models'

export const transformFromApi = (pattern: PatternResponse): Pattern => {
  return {
    id: pattern.id,
    matchText: pattern.match_text,
    notes: pattern.notes,
    categoryId: pattern.category_id,
    subcategoryId: pattern.subcategory_id,
  }
}

export const transformToApi = (pattern: Pattern): PatternRequest => {
  return {
    match_text: pattern.matchText,
    notes: pattern.notes,
    category_id: pattern.categoryId,
    subcategory_id: pattern.subcategoryId,
  }
}
