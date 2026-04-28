// Simulacion en memoria para desarrollo local (VITE_USE_MOCKS=true o APEX_MODE=false)
let _data = [
  { id: 1,  nombre: 'Empresa Alpha SA',      email: 'contacto@alpha.com',  ciudad: 'Ciudad de México', pais: 'MX' },
  { id: 2,  nombre: 'Beta Comercial',        email: 'ventas@beta.com',     ciudad: 'Guadalajara',      pais: 'MX' },
  { id: 3,  nombre: 'Gamma Industries',      email: 'info@gamma.com',      ciudad: 'Monterrey',        pais: 'MX' },
  { id: 4,  nombre: 'Delta Corp',            email: 'hola@delta.com',      ciudad: 'Bogotá',           pais: 'CO' },
  { id: 5,  nombre: 'Epsilon Tech',          email: 'tech@epsilon.com',    ciudad: 'Lima',             pais: 'PE' },
  { id: 6,  nombre: 'Zeta Solutions',        email: 'info@zeta.com',       ciudad: 'Buenos Aires',     pais: 'AR' },
  { id: 7,  nombre: 'Eta Distribuidores',    email: 'dist@eta.com',        ciudad: 'Puebla',           pais: 'MX' },
  { id: 8,  nombre: 'Theta Global',          email: 'global@theta.com',    ciudad: 'Santiago',         pais: 'CL' },
]
let _nextId = 100

const delay = () => new Promise(r => setTimeout(r, 200))

export const clientesMocks = {
  list: async () => {
    await delay()
    return [..._data]
  },
  create: async ({ nombre, email, ciudad, pais }) => {
    await delay()
    const c = { id: _nextId++, nombre, email: email || '', ciudad: ciudad || '', pais: pais || 'MX' }
    _data = [..._data, c]
    return { id: c.id, success: true }
  },
  update: async ({ id, nombre, email, ciudad, pais }) => {
    await delay()
    _data = _data.map(c =>
      c.id === Number(id)
        ? { id: Number(id), nombre, email: email || '', ciudad: ciudad || '', pais: pais || 'MX' }
        : c
    )
    return { success: true }
  },
  delete: async (id) => {
    await delay()
    _data = _data.filter(c => c.id !== Number(id))
    return { success: true }
  },
}
