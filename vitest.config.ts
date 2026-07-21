import { defineConfig } from 'vitest/config'
import { resolve } from 'path'

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    environmentOptions: {
      jsdom: {
        url: 'http://localhost:3000',
      },
    },
    setupFiles: ['./spec/javascript/vitestSetup.ts'],
  },
  resolve: {
    alias: {
      actions: resolve(__dirname, 'app/javascript/actions'),
      components: resolve(__dirname, 'app/javascript/components'),
      hooks: resolve(__dirname, 'app/javascript/hooks'),
      mocks: resolve(__dirname, 'spec/javascript/mocks'),
      selectors: resolve(__dirname, 'app/javascript/selectors'),
      stores: resolve(__dirname, 'app/javascript/stores'),
      stylesheets: resolve(__dirname, 'app/javascript/stylesheets'),
      transformers: resolve(__dirname, 'app/javascript/transformers'),
      types: resolve(__dirname, 'app/javascript/types'),
      util: resolve(__dirname, 'app/javascript/util'),
    },
  },
})
