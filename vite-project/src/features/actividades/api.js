import { callProcess, USE_MOCKS } from "@/api/apexClient";
import { unwrap, unwrapOne } from "@/api/utils";

const MOCKS = {
  actividades: [
    {
      id_actividad: 1,
      tipo: "Llamada",
      asunto: "Seguimiento propuesta PVC",
      descripcion: "Llamada de seguimiento",
      fecha: "2026-05-02",
      virtual: "N",
      completada: "N",
      id_oportunidad: 2,
      ejecutivo_nombre: "Ana Martínez",
    },
    {
      id_actividad: 2,
      tipo: "Visita",
      asunto: "Presentación portafolio",
      descripcion: "Visita presencial",
      fecha: "2026-05-05",
      virtual: "N",
      completada: "N",
      id_oportunidad: 1,
      ejecutivo_nombre: "Ana Martínez",
    },
    {
      id_actividad: 3,
      tipo: "Reunión",
      asunto: "Revisión propuesta técnica",
      descripcion: "Reunión virtual",
      fecha: "2026-04-28",
      virtual: "S",
      completada: "S",
      id_oportunidad: 3,
      ejecutivo_nombre: "Luis Pérez",
    },
  ],
};

export const actividadesApi = {
  listar: ({ idUsuario, fechaDesde, fechaHasta, tipo } = {}) =>
    USE_MOCKS
      ? Promise.resolve(MOCKS.actividades)
      : callProcess("ACTIVIDADES_LIST", {
          x01: idUsuario,
          x02: fechaDesde,
          x03: fechaHasta,
          x04: tipo,
        }).then(unwrap),

  listarTodas: ({ fechaDesde, fechaHasta } = {}) =>
    USE_MOCKS
      ? Promise.resolve(MOCKS.actividades)
      : callProcess("ACTIVIDADES_ALL_FOR_COORD", {
          x01: fechaDesde,
          x02: fechaHasta,
        }).then(unwrap),

  buscar: (id) =>
    USE_MOCKS
      ? Promise.resolve(
          MOCKS.actividades.find((a) => a.id_actividad === Number(id)) ??
            MOCKS.actividades[0],
        )
      : callProcess("ACTIVIDADES_GET", { x01: id }).then(unwrapOne),

  crear: (data) =>
    USE_MOCKS
      ? Promise.resolve({ id_actividad: Date.now(), success: "true" })
      : callProcess("ACTIVIDADES_CREATE", {
          x01: data.tipo,
          x02: data.asunto,
          x03: data.descripcion,
          x04: data.id_lead,
          x05: data.id_oportunidad,
          x06: data.fecha,
          x07: data.virtual ? "S" : "N",
        }).then(unwrapOne),

  completar: (data) =>
    USE_MOCKS
      ? Promise.resolve({ success: "true" })
      : callProcess("ACTIVIDADES_COMPLETAR", {
          x01: data.id,
          x02: data.resultado,
          x03: data.latitud,
          x04: data.longitud,
        }).then(unwrapOne),
};
