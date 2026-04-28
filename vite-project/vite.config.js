import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const ordsBase = env.VITE_ORDS_BASE || 'http://localhost:8080/ords/ventas'

  return {
    plugins: [react()],
    build: {
      // Nombres fijos (sin hash) para referenciarlos facilmente en APEX
      rollupOptions: {
        output: {
          entryFileNames: 'assets/app.js',
          chunkFileNames: 'assets/[name].js',
          assetFileNames: 'assets/[name][extname]',
        },
      },
    },
    server: {
      proxy: {
        // Cuando el front llama a /api/* en dev, Vite lo reenvia a ORDS.
        // Esto evita problemas de CORS y mantiene el codigo igual en prod.
        '/api': {
          target: ordsBase,
          changeOrigin: true,
          secure: false,
          rewrite: (path) => path.replace(/^\/api/, ''),
        },
      },
    },
  }
})
