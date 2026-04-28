# vite-project — Frontend React

Aplicacion React del proyecto APEX + React + ORDS. Ver la documentacion completa en la raiz del repositorio.

## Comandos

```bash
npm install          # instalar dependencias
npm run dev          # servidor de desarrollo en http://localhost:5173
npm run build        # bundle de produccion en dist/
npm run lint         # revisar el codigo con ESLint
npm run preview      # previsualizar el build de produccion localmente
```

## Variables de entorno

Copiar `.env.example` como `.env.development` y ajustar:

```env
VITE_APEX_MODE=false                            # false=ORDS, true=APEX On-Demand
VITE_ORDS_BASE=http://localhost:8080/ords/ventas # URL de tu instancia ORDS
```

Para produccion dentro de APEX, `.env.production` solo necesita:

```env
VITE_APEX_MODE=true
```

## Documentacion completa

Ver [../docs/](../docs/) para guias detalladas de arquitectura, componentes, API y despliegue.
