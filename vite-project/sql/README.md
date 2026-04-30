# SQL - Guia de ejecucion

Todos los scripts son **idempotentes**: si las tablas ya existen, las elimina y recrea.

## Orden de ejecucion

### 1. Base comun (dashboard existente)

```sql
@sql/01_tables.sql          -- Tablas demo: CLIENTES, VENDEDORES, PRODUCTOS, VENTAS
@sql/02_views_package.sql   -- Vistas analiticas + pkg_dashboard
@sql/05_apex_processes.sql  -- Application Processes del dashboard
@sql/07_crud_clientes.sql   -- pkg_clientes (CRUD de clientes)
```

### 2. CRM - Oportunidades

```sql
@sql/oportunidades/01_oportunidades_tables.sql      -- Tablas CRM_OPORTUNIDADES, estados, catalogos
@sql/oportunidades/02_oportunidades_package.sql     -- pkg_crm_oportunidades
@sql/oportunidades/03_oportunidades_apex_processes.sql  -- Application Processes OPP_*
```

### 3. CRM - Leads

```sql
@sql/leads/01_leads_tables.sql      -- Tablas CRM_LEADS, estados, origenes, intereses
@sql/leads/02_leads_package.sql     -- pkg_crm_leads (incluye p_convertir que crea OPP)
@sql/leads/03_leads_apex_processes.sql  -- Application Processes LEADS_*
```

> **Importante:** Los scripts de `leads` deben ejecutarse **despues** de `oportunidades` porque `pkg_crm_leads.p_convertir` inserta en `crm_oportunidades`.

### 4. CRM - Actividades

```sql
@sql/actividades/01_actividades_tables.sql      -- Tablas CRM_ACTIVIDADES, tipos
@sql/actividades/02_actividades_package.sql     -- pkg_crm_actividades
@sql/actividades/03_actividades_apex_processes.sql  -- Application Processes ACTIVIDADES_*
```

### 5. CRM - Usuarios

```sql
@sql/usuarios/01_usuarios_tables.sql      -- Tablas CRM_USUARIOS, departamentos
@sql/usuarios/02_usuarios_package.sql     -- pkg_crm_usuarios
@sql/usuarios/03_usuarios_apex_processes.sql  -- Application Processes ADMIN_USUARIOS_*
```

### 6. CRM - Proyectos

```sql
@sql/proyectos/01_proyectos_tables.sql      -- Tablas CRM_PROYECTOS, estados, hitos
@sql/proyectos/02_proyectos_package.sql     -- pkg_crm_proyectos
@sql/proyectos/03_proyectos_apex_processes.sql  -- Application Processes PROYECTOS_*
```

---

## Estructura de carpetas

```
sql/
  01_tables.sql                    # Base demo (dashboard)
  02_views_package.sql             # Vistas + pkg_dashboard
  05_apex_processes.sql            # Procesos APEX dashboard
  07_crud_clientes.sql             # pkg_clientes

  oportunidades/
    01_oportunidades_tables.sql    -- Tablas de oportunidades
    02_oportunidades_package.sql  -- pkg_crm_oportunidades
    03_oportunidades_apex_processes.sql  -- Procesos APEX OPP_*

  leads/
    01_leads_tables.sql           -- Tablas de leads
    02_leads_package.sql          -- pkg_crm_leads
    03_leads_apex_processes.sql   -- Procesos APEX LEADS_*

  actividades/
    01_actividades_tables.sql     -- Tablas de actividades
    02_actividades_package.sql    -- pkg_crm_actividades
    03_actividades_apex_processes.sql  -- Procesos APEX ACTIVIDADES_*

  usuarios/
    01_usuarios_tables.sql        -- Tablas de usuarios
    02_usuarios_package.sql       -- pkg_crm_usuarios
    03_usuarios_apex_processes.sql  -- Procesos APEX ADMIN_USUARIOS_*

  proyectos/
    01_proyectos_tables.sql       -- Tablas de proyectos
    02_proyectos_package.sql      -- pkg_crm_proyectos
    03_proyectos_apex_processes.sql  -- Procesos APEX PROYECTOS_*
```

---

## Tablas CRM - Resumen

### Oportunidades

| Tabla | Descripcion |
|-------|-------------|
| `crm_oportunidades` | Cabecera de oportunidad |
| `crm_estado_oportunidad` | Estados (tipo: ABIERTO/CERRADO_GANADO/CERRADO_PERDIDO) |
| `crm_tipo_oportunidad` | Tipos (Nuevo negocio, Expansion, Renovacion, Licitacion) |
| `crm_sector` | Sectores (Construccion, Industrial, etc.) |
| `crm_motivo_cierre` | Motivos de cierre (GANADA/PERDIDA) |
| `crm_oportunidades_actividades` | Historial de actividades |
| `crm_productos_opp` | Catalogo de productos para presupuestos |

### Leads

| Tabla | Descripcion |
|-------|-------------|
| `crm_leads` | Cabecera de lead |
| `crm_estado_lead` | Estados (tipo: ABIERTO/CALIFICADO/DESCALIFICADO) |
| `crm_origen_lead` | Orgenes (Web, Referido, WhatsApp, etc.) |
| `crm_interes` | Intereses del lead |
| `crm_motivo_descalificacion` | Motivos de descalificacion |

### Actividades

| Tabla | Descripcion |
|-------|-------------|
| `crm_actividades` | Cabecera de actividad |
| `crm_tipo_actividad` | Tipos (Llamada, Visita, Reunión, Email, Demo) |

### Usuarios

| Tabla | Descripcion |
|-------|-------------|
| `crm_usuarios` | Usuarios del sistema CRM |
| `crm_departamento` | Departamentos (Ventas, Coordinación, Dirección, Admin) |

### Proyectos

| Tabla | Descripcion |
|-------|-------------|
| `crm_proyectos` | Cabecera de proyecto |
| `crm_estado_proyecto` | Estados (ACTIVO, PAUSADO, FINALIZADO, CANCELADO) |
| `crm_hitos` | Hitos/milenstones de cada proyecto |

---

## Application Processes requeridos

### Oportunidades (10 procesos)

| Nombre | Parametros |
|--------|------------|
| `OPP_LIST` | x01=id_usuario (opcional) |
| `OPP_GET` | x01=id_oportunidad |
| `OPP_ACTIVIDADES` | x01=id_oportunidad |
| `OPP_CATALOGOS` | ninguno |
| `OPP_PRODUCTOS_CATALOGO` | ninguno |
| `OPP_CREATE` | x01-x10 (ver `03_oportunidades_apex_processes.sql`) |
| `OPP_UPDATE` | x01-x10 (ver `03_oportunidades_apex_processes.sql`) |
| `OPP_AVANZAR_ESTADO` | x01=id, x02=estado, x03=comentario |
| `OPP_CERRAR_GANADA` | x01=id, x02=valor, x03=motivo, x04=desc |
| `OPP_CERRAR_PERDIDA` | x01=id, x02=motivo, x03=desc |
| `OPP_ESTANCADOS` | x01=id_usuario (opcional) |

### Leads (8 procesos)

| Nombre | Parametros |
|--------|------------|
| `LEADS_CATALOGOS` | ninguno |
| `LEADS_LIST` | x01=id_usuario (opcional) |
| `LEADS_GET` | x01=id_lead |
| `LEADS_HISTORIAL` | x01=id_lead |
| `LEADS_CREATE` | x01-x10 (ver `03_leads_apex_processes.sql`) |
| `LEADS_UPDATE` | x01-x11 (ver `03_leads_apex_processes.sql`) |
| `LEADS_DESCALIFICAR` | x01=id, x02=motivo, x03=observacion |
| `LEADS_CONVERTIR` | x01-x12 (ver `03_leads_apex_processes.sql`) |

### Actividades (5 procesos)

| Nombre | Parametros |
|--------|------------|
| `ACTIVIDADES_LIST` | x01=id_usuario, x02=fecha_desde, x03=fecha_hasta, x04=tipo |
| `ACTIVIDADES_ALL_FOR_COORD` | x01=fecha_desde, x02=fecha_hasta |
| `ACTIVIDADES_GET` | x01=id_actividad |
| `ACTIVIDADES_CREATE` | x01-x08 (ver `03_actividades_apex_processes.sql`) |
| `ACTIVIDADES_COMPLETAR` | x01=id, x02=resultado, x03=latitud, x04=longitud |

### Usuarios (3 procesos)

| Nombre | Parametros |
|--------|------------|
| `ADMIN_USUARIOS_LIST` | ninguno |
| `ADMIN_USUARIOS_CREATE` | x01=nombre, x02=email, x03=rol, x04=id_departamento |
| `ADMIN_USUARIOS_TOGGLE` | x01=id_usuario, x02=activo (S/N) |

### Proyectos (4 procesos)

| Nombre | Parametros |
|--------|------------|
| `PROYECTOS_LIST` | x01=id_usuario (opcional) |
| `PROYECTOS_GET` | x01=id_proyecto |
| `PROYECTOS_CREATE` | x01-x05 (ver `03_proyectos_apex_processes.sql`) |
| `PROYECTOS_UPDATE` | x01-x06 (ver `03_proyectos_apex_processes.sql`) |

---

## Validacion

Despues de ejecutar los scripts, puedes verificar con:

```sql
-- Verificar tablas CRM
SELECT table_name FROM user_tables WHERE table_name LIKE 'CRM_%' ORDER BY table_name;

-- Verificar paquetes
SELECT object_name, status FROM user_objects
WHERE object_type IN ('PACKAGE','PACKAGE BODY')
ORDER BY object_name;

-- Verificar secuencias
SELECT sequence_name FROM user_sequences WHERE sequence_name LIKE 'SEQ_CRM_%';
```
