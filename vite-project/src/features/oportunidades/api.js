import { callProcess, USE_MOCKS } from "@/api/apexClient";
import { unwrap, unwrapOne } from "@/api/utils";

const MOCKS = {
  oportunidades: [
    {
      id_oportunidad: 1,
      titulo: "Suministro perfiles estructurales",
      valor_estimado: 45000000,
      probabilidad_cierre: 70,
      id_estado_oportunidad: 1,
      estado_nombre: "Prospecto",
      fecha_cierre_estimada: "2026-06-30",
      id_usuario: 1,
      ejecutivo_nombre: "Ana Martínez",
    },
    {
      id_oportunidad: 2,
      titulo: "Proyecto PVC residencial Medellín",
      valor_estimado: 28000000,
      probabilidad_cierre: 50,
      id_estado_oportunidad: 2,
      estado_nombre: "Calificación",
      fecha_cierre_estimada: "2026-07-15",
      id_usuario: 1,
      ejecutivo_nombre: "Ana Martínez",
    },
    {
      id_oportunidad: 3,
      titulo: "Licitación tubería industrial",
      valor_estimado: 120000000,
      probabilidad_cierre: 30,
      id_estado_oportunidad: 3,
      estado_nombre: "Propuesta",
      fecha_cierre_estimada: "2026-05-20",
      id_usuario: 2,
      ejecutivo_nombre: "Luis Pérez",
    },
    {
      id_oportunidad: 4,
      titulo: "Renovación contrato anual",
      valor_estimado: 65000000,
      probabilidad_cierre: 80,
      id_estado_oportunidad: 4,
      estado_nombre: "Negociación",
      fecha_cierre_estimada: "2026-05-10",
      id_usuario: 2,
      ejecutivo_nombre: "Luis Pérez",
    },
  ],
  catalogos: {
    estados: [
      { id_estado_oportunidad: 1, nombre: "Prospecto", tipo: "ABIERTO" },
      { id_estado_oportunidad: 2, nombre: "Calificación", tipo: "ABIERTO" },
      { id_estado_oportunidad: 3, nombre: "Propuesta", tipo: "ABIERTO" },
      { id_estado_oportunidad: 4, nombre: "Negociación", tipo: "ABIERTO" },
      { id_estado_oportunidad: 5, nombre: "Ganada", tipo: "CERRADO_GANADO" },
      { id_estado_oportunidad: 6, nombre: "Perdida", tipo: "CERRADO_PERDIDO" },
    ],
  },
  productos: [
    { id_producto: 1, nombre: "Perfil U 40×40", precio_referencia: 15000 },
    { id_producto: 2, nombre: 'Tubo PVC 4"', precio_referencia: 8500 },
    { id_producto: 3, nombre: "Perfil L 50×50", precio_referencia: 18000 },
    { id_producto: 4, nombre: 'Tubería CPVC 1"', precio_referencia: 12000 },
  ],
};

export const oportunidadesApi = {
  listar: (idUsuario) =>
    USE_MOCKS
      ? Promise.resolve(MOCKS.oportunidades)
      : callProcess("OPP_LIST", idUsuario ? { x01: idUsuario } : {}).then(
          unwrap,
        ),

  buscar: (id) =>
    USE_MOCKS
      ? Promise.resolve(
          MOCKS.oportunidades.find((o) => o.id_oportunidad === Number(id)) ??
            MOCKS.oportunidades[0],
        )
      : callProcess("OPP_GET", { x01: id }).then(unwrapOne),

  actividades: (id) =>
    USE_MOCKS
      ? Promise.resolve([])
      : callProcess("OPP_ACTIVIDADES", { x01: id }).then(unwrap),

  catalogos: () =>
    USE_MOCKS
      ? Promise.resolve(MOCKS.catalogos)
      : callProcess("OPP_PRODUCTOS_CATALOGO").then(unwrap),

  productos: () =>
    USE_MOCKS
      ? Promise.resolve(MOCKS.productos)
      : callProcess("OPP_PRODUCTOS_CATALOGO").then(unwrap),

  crear: (data) =>
    USE_MOCKS
      ? Promise.resolve({ id_oportunidad: Date.now(), success: "true" })
      : callProcess("OPP_CREATE", {
          x01: data.titulo,
          x02: data.descripcion,
          x03: data.id_tipo_oportunidad,
          x04: data.id_estado_oportunidad ?? 1,
          x05: data.valor_estimado,
          x06: data.probabilidad_cierre ?? 50,
          x07: data.id_sector,
          x08: data.id_empresa,
          x09: data.fecha_cierre_estimada,
          x10: data.id_usuario,
        }).then(unwrapOne),

  actualizar: (id, data) =>
    USE_MOCKS
      ? Promise.resolve({ success: "true" })
      : callProcess("OPP_UPDATE", {
          x01: id,
          x02: data.titulo,
          x03: data.id_tipo_oportunidad,
          x04: data.id_estado_oportunidad,
          x05: data.valor_estimado,
          x06: data.probabilidad_cierre,
          x07: data.id_sector,
          x08: data.id_empresa,
          x09: data.fecha_cierre_estimada,
        }).then(unwrapOne),

  avanzarEstado: (id, idEstadoNuevo, comentario) =>
    USE_MOCKS
      ? Promise.resolve({ success: "true" })
      : callProcess("OPP_AVANZAR_ESTADO", {
          x01: id,
          x02: idEstadoNuevo,
          x03: comentario,
        }).then(unwrapOne),

  cerrarGanada: (id, data) =>
    USE_MOCKS
      ? Promise.resolve({ success: "true" })
      : callProcess("OPP_CERRAR_GANADA", {
          x01: id,
          x02: data.valor_final,
          x03: data.id_motivo,
          x04: data.descripcion,
        }).then(unwrapOne),

  cerrarPerdida: (id, data) =>
    USE_MOCKS
      ? Promise.resolve({ success: "true" })
      : callProcess("OPP_CERRAR_PERDIDA", {
          x01: id,
          x02: data.id_motivo,
          x03: data.descripcion,
        }).then(unwrapOne),

  estancados: (idUsuario) =>
    USE_MOCKS
      ? Promise.resolve([])
      : callProcess("OPP_ESTANCADOS", idUsuario ? { x01: idUsuario } : {}).then(
          unwrap,
        ),
};
