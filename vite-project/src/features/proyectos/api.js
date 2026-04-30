import { callProcess, USE_MOCKS } from '@/api/apexClient'
import { unwrap, unwrapOne } from '@/api/utils'

const MOCKS = {
  proyectos: [
    { id_proyecto: 1, nombre: 'Instalación perfiles Bogotá',   descripcion: 'Suministro e instalación zona norte', estado: 'ACTIVO',     fecha_inicio: '2026-04-01', fecha_fin: '2026-06-30', id_oportunidad: 1, hitos: [] },
    { id_proyecto: 2, nombre: 'Proyecto PVC Medellín',         descripcion: 'Tuberías residenciales barrio nuevo',  estado: 'PAUSADO',    fecha_inicio: '2026-03-15', fecha_fin: '2026-07-15', id_oportunidad: 2, hitos: [] },
    { id_proyecto: 3, nombre: 'Licitación tubería industrial', descripcion: 'Tubería de alta presión planta',       estado: 'FINALIZADO', fecha_inicio: '2025-11-01', fecha_fin: '2026-04-30', id_oportunidad: 3, hitos: [] },
  ],
}

export const proyectosApi = {
  listar: (idUsuario) => USE_MOCKS
    ? Promise.resolve(MOCKS.proyectos)
    : callProcess('PROYECTOS_LIST', idUsuario ? { x01: idUsuario } : {}).then(unwrap),

  buscar: (id) => USE_MOCKS
    ? Promise.resolve(MOCKS.proyectos.find(p => p.id_proyecto === Number(id)) ?? MOCKS.proyectos[0])
    : callProcess('PROYECTOS_GET', { x01: id }).then(unwrapOne),

  crear: (data) => USE_MOCKS
    ? Promise.resolve({ id_proyecto: Date.now(), success: 'true' })
    : callProcess('PROYECTOS_CREATE', {
        x01: data.nombre,
        x02: data.descripcion,
        x03: data.id_oportunidad,
        x04: data.fecha_inicio,
        x05: data.fecha_fin,
      }).then(unwrapOne),

  actualizar: (id, data) => USE_MOCKS
    ? Promise.resolve({ success: 'true' })
    : callProcess('PROYECTOS_UPDATE', {
        x01: id,
        x02: data.nombre,
        x03: data.descripcion,
        x04: data.fecha_inicio,
        x05: data.fecha_fin,
        x06: data.estado,
      }).then(unwrapOne),
}
