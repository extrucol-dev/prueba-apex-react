// Datos mock con la MISMA forma que devuelven los endpoints ORDS.
// Asi el dashboard se desarrolla sin necesidad de Oracle corriendo.

export const kpis = () => [{
  ingresos_total:    4_812_345.50,
  ingresos_mes:        612_980.25,
  num_ventas:               223,
  ventas_hoy:                 4,
  num_clientes:               8,
  num_productos:             10,
  ticket_promedio:      21_580.92,
  ventas_pendientes:         12,
}]

export const ventasMensuales = () => {
  const meses = [
    'May 25','Jun 25','Jul 25','Ago 25','Sep 25','Oct 25',
    'Nov 25','Dic 25','Ene 26','Feb 26','Mar 26','Abr 26',
  ]
  let base = 280_000
  return meses.map((etiqueta, i) => {
    base = base * (0.92 + Math.random() * 0.25)
    return {
      periodo: `2025-${String((i + 5) % 12 || 12).padStart(2, '0')}`,
      etiqueta,
      num_ventas: 12 + Math.floor(Math.random() * 18),
      total_ventas: Math.round(base),
      ticket_promedio: Math.round(base / 18),
    }
  })
}

export const topProductos = () => ([
  { id: 1, nombre: 'Laptop Pro 14',     categoria: 'Computo',    unidades:  82, ingresos: 2_377_918 },
  { id: 5, nombre: 'Smartphone X',      categoria: 'Telefonia',  unidades: 110, ingresos: 1_758_900 },
  { id: 8, nombre: 'Tablet 11"',        categoria: 'Computo',    unidades:  95, ingresos:   854_050 },
  { id: 2, nombre: 'Monitor 27" 4K',    categoria: 'Computo',    unidades:  72, ingresos:   575_280 },
  { id: 9, nombre: 'Impresora Multif.', categoria: 'Oficina',    unidades:  88, ingresos:   403_920 },
])

export const ventasCategoria = () => ([
  { categoria: 'Computo',    ingresos: 3_807_248, unidades: 249 },
  { categoria: 'Telefonia',  ingresos: 1_758_900, unidades: 110 },
  { categoria: 'Oficina',    ingresos:   612_400, unidades: 134 },
  { categoria: 'Audio',      ingresos:   428_710, unidades: 312 },
  { categoria: 'Accesorios', ingresos:   305_580, unidades: 540 },
  { categoria: 'Mobiliario', ingresos:   197_400, unidades:  60 },
])

export const ventasRegion = () => ([
  { region: 'Centro',    num_ventas: 64, ingresos: 1_438_220 },
  { region: 'Norte',     num_ventas: 51, ingresos: 1_182_900 },
  { region: 'Occidente', num_ventas: 42, ingresos:   976_510 },
  { region: 'Sur',       num_ventas: 38, ingresos:   712_345 },
  { region: 'Sureste',   num_ventas: 28, ingresos:   502_370 },
])

export const ultimasVentas = (limit = 10) => {
  const clientes  = ['Comercial Aurora SA','Distribuidora Maya','Industrias Halcon','Grupo Pacifico','Servicios Andinos','Tecnologias del Sur','Mercantil del Bajio','Suministros del Golfo']
  const vendedores = ['Ana Martinez','Luis Perez','Carla Lopez','Jorge Ramirez','Sofia Diaz']
  const regiones   = ['Norte','Sur','Centro','Occidente','Sureste']
  const estados    = ['PAGADA','PAGADA','PAGADA','PENDIENTE','CANCELADA']
  const out = []
  const today = new Date()
  for (let i = 0; i < limit; i++) {
    const d = new Date(today); d.setDate(today.getDate() - i)
    out.push({
      id: 1000 + i,
      fecha: d.toISOString().slice(0, 10),
      cliente:  clientes[i % clientes.length],
      vendedor: vendedores[i % vendedores.length],
      region:   regiones[i % regiones.length],
      total:    Math.round(8_000 + Math.random() * 60_000),
      estado:   estados[i % estados.length],
    })
  }
  return out
}
