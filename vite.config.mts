import { defineConfig } from 'vite'
import { resolve } from 'path'
import RubyPlugin from 'vite-plugin-ruby'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [RubyPlugin(), react()],
  resolve: {
    alias: {
      actions: resolve(__dirname, 'app/javascript/actions'),
      components: resolve(__dirname, 'app/javascript/components'),
      hooks: resolve(__dirname, 'app/javascript/hooks'),
      stores: resolve(__dirname, 'app/javascript/stores'),
      stylesheets: resolve(__dirname, 'app/javascript/stylesheets'),
      transformers: resolve(__dirname, 'app/javascript/transformers'),
      types: resolve(__dirname, 'app/javascript/types'),
      util: resolve(__dirname, 'app/javascript/util'),
    },
  },
})
