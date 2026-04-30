import { callProcess, USE_MOCKS } from '@/api/apexClient'
import { unwrap, unwrapOne } from '@/api/utils'

const MOCKS = {
  ejecutivoKpis: {
    leads_activos:      12,
    opp_activas:         8,
    pipeline_valor:  187000000,
    actividades_hoy:     3,
  },
  ejecutivoOpp: [
    { id_oportunidad: 1, titulo: 'Suministro perfiles', valor_estimado: 45000000, estado_nombre: 'Propuesta',   fecha_cierre_estimada: '2026-06-30' },
    { id_oportunidad: 2, titulo: 'Proyecto PVC',        valor_estimado: 28000000, estado_nombre: 'Calificación', fecha_cierre_estimada: '2026-07-15' },
    { id_oportunidad: 3, titulo: 'Licitación tubería',  valor_estimado: 120000000, estado_nombre: 'Negociación', fecha_cierre_estimada: '2026-05-20' },
  ],
  ejecutivoAct: [
    { id_actividad: 1, tipo: 'Llamada', asunto: 'Seguimiento propuesta PVC', fecha: '2026-05-02' },
    { id_actividad: 2, tipo: 'Visita',  asunto: 'Presentación portafolio',   fecha: '2026-05-05' },
  ],
  directorKpis: {
    pipeline_total:     450000000,
    opp_ganadas_mes:    3,
    tasa_conversion:    0.28,
    ticket_promedio:    56250000,
    ejecutivos_activos: 5,
  },
  directorFunnel: [
    { estado: 'Prospecto',    cantidad: 18, valor: 320000000 },
    { estado: 'Calificación', cantidad: 12, valor: 280000000 },
    { estado: 'Propuesta',    cantidad:  8, valor: 185000000 },
    { estado: 'Negociación',  cantidad:  4, valor:  95000000 },
  ],
}

export const dashboardApi = {
  // Ejecutivo
  ejecutivoKpis: (idUsuario) => USE_MOCKS
    ? Promise.resolve(MOCKS.ejecutivoKpis)
    : callProcess('DASH_EJECUTIVO_KPIS', { x01: idUsuario }).then(unwrapOne),

  ejecutivoOpp: (idUsuario) => USE_MOCKS
    ? Promise.resolve(MOCKS.ejecutivoOpp)
    : callProcess('DASH_EJECUTIVO_OPP', { x01: idUsuario }).then(unwrap),

  ejecutivoAct: (idUsuario) => USE_MOCKS
    ? Promise.resolve(MOCKS.ejecutivoAct)
    : callProcess('DASH_EJECUTIVO_ACT', { x01: idUsuario }).then(unwrap),

  // Director
  directorKpis: () => USE_MOCKS
    ? Promise.resolve(MOCKS.directorKpis)
    : callProcess('DASH_DIRECTOR_KPIS').then(unwrapOne),

  directorFunnel: () => USE_MOCKS
    ? Promise.resolve(MOCKS.directorFunnel)
    : callProcess('DASH_DIRECTOR_FUNNEL').then(unwrap),

  directorEquipo: () => USE_MOCKS
    ? Promise.resolve([])
    : callProcess('DASH_DIRECTOR_EQUIPO').then(unwrap),

  // Coordinador
  coordinadorKpis: () => USE_MOCKS
    ? Promise.resolve({})
    : callProcess('DASH_COORDINADOR_KPIS').then(unwrapOne),

  coordinadorEquipo: () => USE_MOCKS
    ? Promise.resolve([])
    : callProcess('DASH_COORDINADOR_EQUIPO').then(unwrap),

  coordinadorAlertas: () => USE_MOCKS
    ? Promise.resolve([])
    : callProcess('DASH_COORDINADOR_ALERTAS').then(unwrap),

  // Admin
  adminKpis: () => USE_MOCKS
    ? Promise.resolve({})
    : callProcess('DASH_ADMIN_KPIS').then(unwrapOne),
}
