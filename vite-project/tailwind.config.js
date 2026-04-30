/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './index.html',
    './src/**/*.{js,jsx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#24388C',
        accent:  '#F39610',
        success: '#1A8754',
        error:   '#C0392B',
      },
      borderRadius: {
        sm: '6px',
        md: '8px',
        lg: '12px',
      },
      fontFamily: {
        sans: ['Roboto', 'sans-serif'],
      },
      boxShadow: {
        card:  '0 1px 3px rgba(0,0,0,.08)',
        modal: '0 8px 32px rgba(0,0,0,.18)',
      },
    },
  },
  plugins: [],
}
