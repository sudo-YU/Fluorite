import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()], // Tailwind v4のViteプラグインを追加
  server: {
    host: '0.0.0.0',
    port: 3000,
    watch: {
      usePolling: true,
    },
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
    },
  },
  // ファイルの自動生成を無効化
  build: {
    emptyOutDir: false, // 出力ディレクトリを自動的に空にしない
    write: true, // 既存のファイルを上書きするが、新しいファイルは自動生成しない
  },
})