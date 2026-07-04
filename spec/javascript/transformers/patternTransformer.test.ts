import {
  transformFromApi,
  transformToApi,
} from 'transformers/patternTransformer'

describe('patternTransformer', () => {
  describe('transformFromApi', () => {
    it('converts pattern from API format', () => {
      const pattern = {
        id: 23,
        match_text: 'my text',
        notes: 'my note',
        category_id: 2,
        subcategory_id: 7,
      }

      const transformedPattern = transformFromApi(pattern)

      expect(transformedPattern.id).toEqual(23)
      expect(transformedPattern.matchText).toEqual('my text')
      expect(transformedPattern.notes).toEqual('my note')
      expect(transformedPattern.categoryId).toEqual(2)
      expect(transformedPattern.subcategoryId).toEqual(7)
    })
  })

  describe('transformToApi', () => {
    it('converts new pattern to API format', () => {
      const pattern = {
        id: 23,
        matchText: 'my text',
        notes: 'my note',
        categoryId: 2,
        subcategoryId: 7,
      }

      const transformedPattern = transformToApi(pattern)

      expect(transformedPattern.match_text).toEqual('my text')
      expect(transformedPattern.notes).toEqual('my note')
      expect(transformedPattern.category_id).toEqual(2)
      expect(transformedPattern.subcategory_id).toEqual(7)
    })
  })
})
