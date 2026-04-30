import { callProcess, USE_MOCKS } from '@/api/apexClient'
import { unwrap, unwrapOne } from '@/api/utils'

const MOCKS = {
  leads: [
    {
      id_lead: 1, titulo: 'Constructora Oikos – perfiles PVC', descripcion: 'Interesados en perfiles estructurales para obra nueva.',
      score: 80, id_estado_lead: 1, estado_nombre: 'Nuevo',
      id_origen_lead: 1, origen_nombre: 'Web',
      nombre_empresa: 'Constructora Oikos', nombre_contacto: 'Jorge Rueda',
      telefono_contacto: '3001234567', email_contacto: 'jrueda@oikos.com',
      id_usuario: 1, ejecutivo_nombre: 'Ana Martínez',
      fecha_creacion: '2026-04-01T08:30:00', fecha_actualizacion: '2026-04-10T10:00:00',
      id_oportunidad_generada: null, id_motivo_descalificacion: null,
    },
    {
      id_lead: 2, titulo: 'Ferretería El Maestro – tubería', descripcion: 'Requieren tubería PVC para distribución local.',
      score: 60, id_estado_lead: 2, estado_nombre: 'Contactado',
      id_origen_lead: 2, origen_nombre: 'Referido',
      nombre_empresa: 'Ferretería El Maestro', nombre_contacto: 'María López',
      telefono_contacto: '3109876543', email_contacto: 'mlopez@maestro.co',
      id_usuario: 1, ejecutivo_nombre: 'Ana Martínez',
      fecha_creacion: '2026-04-05T09:00:00', fecha_actualizacion: '2026-04-15T14:00:00',
      id_oportunidad_generada: null, id_motivo_descalificacion: null,
    },
    {
      id_lead: 3, titulo: 'Ingeniería Vital – licitación 2026', descripcion: 'Licitación pública para tubería de acueducto municipal.',
      score: 75, id_estado_lead: 3, estado_nombre: 'Calificado',
      id_origen_lead: 4, origen_nombre: 'Feria comercial',
      nombre_empresa: 'Ingeniería Vital', nombre_contacto: 'Carlos Díaz',
      telefono_contacto: '3154567890', email_contacto: 'cdiaz@vital.com.co',
      id_usuario: 2, ejecutivo_nombre: 'Luis Pérez',
      fecha_creacion: '2026-03-20T11:00:00', fecha_actualizacion: '2026-04-20T16:30:00',
      id_oportunidad_generada: null, id_motivo_descalificacion: null,
    },
    {
      id_lead: 4, titulo: 'Grupo Constructor Andino', descripcion: 'Proyecto residencial, pero presupuesto no alcanza.',
      score: 15, id_estado_lead: 4, estado_nombre: 'Descalificado',
      id_origen_lead: 3, origen_nombre: 'Llamada fría',
      nombre_empresa: 'Grupo Andino', nombre_contacto: 'Sandra Torres',
      telefono_contacto: '3187654321', email_contacto: 'storres@andino.co',
      id_usuario: 2, ejecutivo_nombre: 'Luis Pérez',
      fecha_creacion: '2026-03-10T10:00:00', fecha_actualizacion: '2026-04-01T09:00:00',
      id_oportunidad_generada: null, id_motivo_descalificacion: 1,
    },
  ],
  catalogos: {
    // tipo: ABIERTO | CALIFICADO | DESCALIFICADO  (según CRM_ESTADO_LEAD del ER v6)
    estados: [
      { id_estado_lead: 1, nombre: 'Nuevo',         tipo: 'ABIERTO',        orden: 1, color_hex: '#3b82f6' },
      { id_estado_lead: 2, nombre: 'Contactado',    tipo: 'ABIERTO',        orden: 2, color_hex: '#f59e0b' },
      { id_estado_lead: 3, nombre: 'Calificado',    tipo: 'CALIFICADO',     orden: 3, color_hex: '#10b981' },
      { id_estado_lead: 4, nombre: 'Descalificado', tipo: 'DESCALIFICADO',  orden: 4, color_hex: '#ef4444' },
    ],
    origenes: [
      { id_origen_lead: 1, nombre: 'Web',             color_hex: '#6366f1' },
      { id_origen_lead: 2, nombre: 'Referido',        color_hex: '#f59e0b' },
      { id_origen_lead: 3, nombre: 'Llamada fría',    color_hex: '#64748b' },
      { id_origen_lead: 4, nombre: 'Feria comercial', color_hex: '#ec4899' },
      { id_origen_lead: 5, nombre: 'WhatsApp',        color_hex: '#22c55e' },
      { id_origen_lead: 6, nombre: 'Instagram',       color_hex: '#a855f7' },
    ],
    intereses: [
      { id_interes: 1, nombre: 'Perfiles estructurales' },
      { id_interes: 2, nombre: 'Tubería PVC' },
      { id_interes: 3, nombre: 'Tubería CPVC' },
      { id_interes: 4, nombre: 'Accesorios PE' },
      { id_interes: 5, nombre: 'Válvulas' },
      { id_interes: 6, nombre: 'Riego' },
    ],
    motivos_descalificacion: [
      { id_motivo_descalificacion: 1, nombre: 'Presupuesto insuficiente' },
      { id_motivo_descalificacion: 2, nombre: 'No es el decisor' },
      { id_motivo_descalificacion: 3, nombre: 'No tiene necesidad' },
      { id_motivo_descalificacion: 4, nombre: 'No responde' },
      { id_motivo_descalificacion: 5, nombre: 'Trasladado a distribuidor' },
    ],
  },
}

export const leadsApi = {
  catalogos: () => USE_MOCKS
    ? Promise.resolve(MOCKS.catalogos)
    : callProcess('LEADS_CATALOGOS').then(unwrap),

  listar: (idUsuario) => USE_MOCKS
    ? Promise.resolve(MOCKS.leads)
    : callProcess('LEADS_LIST', idUsuario ? { x02: idUsuario } : {}).then(unwrap),

  buscar: (id) => USE_MOCKS
    ? Promise.resolve(MOCKS.leads.find(l => l.id_lead === Number(id)) ?? MOCKS.leads[0])
    : callProcess('LEADS_GET', { x01: id }).then(unwrapOne),

  historial: (id) => USE_MOCKS
    ? Promise.resolve([])
    : callProcess('LEADS_HISTORIAL', { x01: id }).then(unwrap),

  crear: (data) => USE_MOCKS
    ? Promise.resolve({ id_lead: Date.now(), success: 'true' })
    : callProcess('LEADS_CREATE', {
        x01: data.titulo,
        x02: data.descripcion,
        x03: data.score ?? 60,
        x04: data.id_estado_lead ?? 1,
        x05: data.id_origen_lead ?? 1,
        x06: data.id_usuario,
        x07: data.nombre_empresa,
        x08: data.nombre_contacto,
        x09: data.telefono_contacto,
        x10: data.email_contacto,
      }).then(unwrapOne),

  actualizar: (id, data) => USE_MOCKS
    ? Promise.resolve({ success: 'true' })
    : callProcess('LEADS_UPDATE', {
        x01: id,
        x02: data.titulo,
        x03: data.descripcion,
        x04: data.score,
        x05: data.id_estado_lead,
        x06: data.id_origen_lead,
        x07: data.id_usuario,
        x08: data.nombre_empresa,
        x09: data.nombre_contacto,
        x10: data.telefono_contacto,
        x11: data.email_contacto,
      }).then(unwrapOne),

  descalificar: (id, idMotivo, observacion) => USE_MOCKS
    ? Promise.resolve({ success: 'true' })
    : callProcess('LEADS_DESCALIFICAR', { x01: id, x02: idMotivo, x03: observacion }).then(unwrapOne),

  convertir: (id, data) => USE_MOCKS
    ? Promise.resolve({ id_oportunidad: Date.now(), success: 'true' })
    : callProcess('LEADS_CONVERTIR', {
        x01: id,
        x02: data.titulo_opp,
        x03: data.id_tipo,
        x04: data.id_sector,
        x05: data.descripcion,
        x06: data.id_empresa,
        x07: data.id_usuario,
        x08: data.id_usuario,
        x09: data.valor_estimado,
        x10: data.fecha_cierre,
        x11: data.probabilidad ?? 50,
        x12: 1,
      }).then(unwrapOne),
}
