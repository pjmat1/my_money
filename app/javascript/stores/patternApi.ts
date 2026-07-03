import { Pattern } from 'types/models'
import { PatternResponse } from 'types/api'
import {
  transformFromApi,
  transformToApi,
} from 'transformers/patternTransformer'
import { applicationApi } from './applicationApi'
import { ApiStatus, setStatus, setStatusAndMessage } from './apiStatusSlice'

type ErrorResponse = {
  status: number
  data: { message: string }
}

type Error = {
  error: ErrorResponse
}

export const patternApi = applicationApi.injectEndpoints({
  endpoints: (builder) => ({
    getPatterns: builder.query<Pattern[], void>({
      query() {
        return {
          url: 'patterns',
        }
      },
      transformResponse: (results: { patterns: PatternResponse[] }) =>
        results.patterns.map((pattern) => transformFromApi(pattern)),
      providesTags: () => ['patterns'],
    }),
    upsertPattern: builder.mutation<void, Pattern>({
      query: (pattern) => ({
        url: `patterns${pattern.id ? '/' + pattern.id : ''}`,
        method: pattern.id ? 'PUT' : 'POST',
        body: { pattern: transformToApi(pattern) },
      }),
      invalidatesTags: ['patterns'],
      async onQueryStarted(id, { dispatch, queryFulfilled }) {
        dispatch(setStatus({ status: ApiStatus.LOADING }))
        try {
          const { data } = await queryFulfilled
          dispatch(
            setStatusAndMessage({
              status: ApiStatus.DONE,
              message: 'Pattern saved',
            }),
          )
        } catch (err) {
          const error = err as Error
          dispatch(
            setStatusAndMessage({
              status: ApiStatus.ERROR,
              message: `Error: ${error?.error?.data?.message}`,
            }),
          )
        }
      },
    }),
    deletePattern: builder.mutation<void, Pattern>({
      query: (pattern) => ({
        url: `patterns/${pattern.id}`,
        method: 'DELETE',
      }),
      invalidatesTags: ['patterns'],
      async onQueryStarted(id, { dispatch, queryFulfilled }) {
        dispatch(setStatus({ status: ApiStatus.LOADING }))
        try {
          const { data } = await queryFulfilled
          dispatch(
            setStatusAndMessage({
              status: ApiStatus.DONE,
              message: 'Pattern deleted',
            }),
          )
        } catch (err) {
          const error = err as Error
          dispatch(
            setStatusAndMessage({
              status: ApiStatus.ERROR,
              message: `Error: ${error?.error?.data?.message}`,
            }),
          )
        }
      },
    }),
  }),
})

export const {
  useGetPatternsQuery,
  useUpsertPatternMutation,
  useDeletePatternMutation,
} = patternApi
