// Register jest-dom's matchers (toBeInTheDocument, toHaveAttribute, ...) with
// vitest's expect so component tests can use them.
import '@testing-library/jest-dom/vitest'

// Under jsdom, Node's global Request/fetch (undici) require an absolute URL.
// The app configures RTK Query's fetchBaseQuery with a root-relative baseUrl
// ('/api'), which is valid in the browser but makes Request construction throw
// "Invalid URL: /api/..." in the test environment. Resolve root-relative URLs
// against the jsdom origin so requests build correctly and MSW can intercept
// them. MSW matches its relative handler paths against the same origin, so the
// handlers keep working unchanged.
const ORIGIN = 'http://localhost:3000'

const OriginalRequest = globalThis.Request

class RelativeAwareRequest extends OriginalRequest {
  constructor(input: RequestInfo | URL, init?: RequestInit) {
    if (typeof input === 'string' && input.startsWith('/')) {
      input = `${ORIGIN}${input}`
    }
    super(input, init)
  }
}

globalThis.Request = RelativeAwareRequest as unknown as typeof Request
