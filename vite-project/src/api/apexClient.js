// Cliente para llamar a APEX On-Demand Application Processes.
// Usa apex.server.process() — API oficial de APEX que maneja sesion,
// CSRF y routing automaticamente. Solo funciona dentro de una pagina APEX.

const callProcess = (processName, extras = {}) =>
  new Promise((resolve, reject) => {
    window.apex.server.process(processName, extras, {
      dataType: 'json',
      success:  resolve,
      error:    (jqXHR, status, error) =>
        reject(new Error(`${processName}: ${status} – ${error}`)),
    })
  })

// ---- Dashboard (solo lectura) ----
export const apexDashboardApi = {
  kpis:            ()           => callProcess('DASH_KPIS'),
  ventasMensuales: ()           => callProcess('DASH_VENTAS_MENSUALES'),
  topProductos:    (limit = 5)  => callProcess('DASH_TOP_PRODUCTOS',  { x01: limit }),
  ventasCategoria: ()           => callProcess('DASH_VENTAS_CATEGORIA'),
  ventasRegion:    ()           => callProcess('DASH_VENTAS_REGION'),
  ultimasVentas:   (limit = 10) => callProcess('DASH_ULTIMAS_VENTAS', { x01: limit }),
}

// ---- Clientes (CRUD completo) ----
export const apexClientesApi = {
  list:   ()     => callProcess('CLIENTES_LIST'),
  create: (data) => callProcess('CLIENTES_CREATE', {
    x01: data.nombre,
    x02: data.email,
    x03: data.ciudad,
    x04: data.pais,
  }),
  update: (data) => callProcess('CLIENTES_UPDATE', {
    x01: data.id,
    x02: data.nombre,
    x03: data.email,
    x04: data.ciudad,
    x05: data.pais,
  }),
  delete: (id) => callProcess('CLIENTES_DELETE', { x01: id }),
}
