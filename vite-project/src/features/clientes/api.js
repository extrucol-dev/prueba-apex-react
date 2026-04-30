import { callProcess, USE_MOCKS } from "@/api/apexClient";
import { unwrap, unwrapOne } from "@/api/utils";

const MOCKS = {
  clientes: [
    {
      id_empresa: 1,
      nombre: "Extrucol S.A.S",
      no_documento: "900123456-1",
      municipio: "Bogotá",
      modalidad: "Interior",
      activo: "S",
    },
    {
      id_empresa: 2,
      nombre: "Industrias Halcón",
      no_documento: "800987654-2",
      municipio: "Medellín",
      modalidad: "Interior",
      activo: "S",
    },
    {
      id_empresa: 3,
      nombre: "Comercial Aurora S.A",
      no_documento: "700456123-3",
      municipio: "Cali",
      modalidad: "Interior",
      activo: "S",
    },
    {
      id_empresa: 4,
      nombre: "Distribuidora Maya",
      no_documento: "600321789-4",
      municipio: "Barranquilla",
      modalidad: "Interior",
      activo: "S",
    },
  ],
  contactos: {
    1: [
      {
        id_contacto: 1,
        nombre: "Laura",
        apellido: "Gómez",
        email: "lgomez@extrucol.com",
        telefono: "3001234567",
        es_principal: "S",
      },
    ],
    2: [
      {
        id_contacto: 2,
        nombre: "Pedro",
        apellido: "Torres",
        email: "ptorres@halcon.com.co",
        telefono: "3109876543",
        es_principal: "S",
      },
    ],
  },
};

export const clientesApi = {
  listar: () =>
    USE_MOCKS
      ? Promise.resolve(MOCKS.clientes)
      : callProcess("CLIENTES_LIST").then(unwrap),

  buscar: (id) =>
    USE_MOCKS
      ? Promise.resolve({
          ...(MOCKS.clientes.find((c) => c.id_empresa === Number(id)) ??
            MOCKS.clientes[0]),
          contactos: MOCKS.contactos[id] ?? [],
        })
      : callProcess("CLIENTES_GET", { x01: id }).then(unwrapOne),

  crear: (data) =>
    USE_MOCKS
      ? Promise.resolve({ id_empresa: Date.now(), success: "true" })
      : callProcess("CLIENTES_CREATE", {
          x01: data.nombre,
          x02: data.no_documento,
          x03: data.id_municipio,
          x04: data.id_documento,
          x05: data.id_modalidad,
        }).then(unwrapOne),

  actualizar: (id, data) =>
    USE_MOCKS
      ? Promise.resolve({ success: "true" })
      : callProcess("CLIENTES_UPDATE", {
          x01: id,
          x02: data.nombre,
          x03: data.no_documento,
          x04: data.id_municipio,
        }).then(unwrapOne),

  agregarContacto: (idEmpresa, data) =>
    USE_MOCKS
      ? Promise.resolve({ id_contacto: Date.now(), success: "true" })
      : callProcess("CLIENTES_AGREGAR_CONTACTO", {
          x01: idEmpresa,
          x02: data.nombre,
          x03: data.apellido,
          x04: data.cargo,
          x05: data.email,
          x06: data.telefono,
        }).then(unwrapOne),

  desactivar: (id) =>
    USE_MOCKS
      ? Promise.resolve({ success: "true" })
      : callProcess("CLIENTES_DESACTIVAR", { x01: id }).then(unwrapOne),
};
