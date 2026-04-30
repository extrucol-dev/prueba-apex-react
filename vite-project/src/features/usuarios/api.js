import { callProcess, USE_MOCKS } from '@/api/apexClient'
import { unwrap, unwrapOne } from '@/api/utils'

const MOCKS = {
  usuarios: [
    { id_usuario: 1, nombre: 'Ana Martínez',  email: 'ana@extrucol.com',    rol: 'EJECUTIVO',    activo: 'S', id_departamento: 1 },
    { id_usuario: 2, nombre: 'Luis Pérez',    email: 'luis@extrucol.com',   rol: 'EJECUTIVO',    activo: 'S', id_departamento: 1 },
    { id_usuario: 3, nombre: 'Carlos Ruiz',   email: 'carlos@extrucol.com', rol: 'COORDINADOR',  activo: 'S', id_departamento: 2 },
    { id_usuario: 4, nombre: 'Sofía Díaz',    email: 'sofia@extrucol.com',  rol: 'DIRECTOR',     activo: 'S', id_departamento: 3 },
    { id_usuario: 5, nombre: 'Admin Sistema', email: 'admin@extrucol.com',  rol: 'ADMIN',        activo: 'S', id_departamento: 4 },
  ],
}

export const usuariosApi = {
  listar: () => USE_MOCKS
    ? Promise.resolve(MOCKS.usuarios)
    : callProcess('ADMIN_USUARIOS_LIST').then(unwrap),

  buscar: (id) => USE_MOCKS
    ? Promise.resolve(MOCKS.usuarios.find(u => u.id_usuario === Number(id)) ?? null)
    : callProcess('ADMIN_USUARIOS_LIST').then(r => unwrap(r).find(u => u.id_usuario === Number(id)) ?? null),

  crear: (data) => USE_MOCKS
    ? Promise.resolve({ id_usuario: Date.now(), success: 'true' })
    : callProcess('ADMIN_USUARIOS_CREATE', {
        x01: data.nombre,
        x02: data.email,
        x03: data.rol,
        x04: data.id_departamento,
      }).then(unwrapOne),

  toggleActivo: (id, activo) => USE_MOCKS
    ? Promise.resolve({ success: 'true' })
    : callProcess('ADMIN_USUARIOS_TOGGLE', { x01: id, x02: activo ? 'S' : 'N' }).then(unwrapOne),
}
