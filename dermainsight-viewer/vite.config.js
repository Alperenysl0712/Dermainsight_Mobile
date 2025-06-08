import { resolve } from 'path';

export default {
  root: './',
  build: {
    outDir: './dist',
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
      },
      output: {
        entryFileNames: 'main.js' // sabit isim — Flutter için önemli
      }
    }
  }
};
