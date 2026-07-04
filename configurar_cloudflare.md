# Configurar Cloudflare Pages

## Opcion recomendada: GitHub conectado a Cloudflare

1. Entra a Cloudflare.
2. Ve a Workers & Pages.
3. Elige `Create application`.
4. Elige `Pages`.
5. Conecta GitHub.
6. Selecciona el repositorio `CristianAGR3/SYSTEMCORP`.
7. Configura:
   - Production branch: `main`
   - Framework preset: `None`
   - Build command: vacio
   - Build output directory: `/`
8. Deploy.

Cada vez que ejecutes `subir_main_github_cloudflare.bat`, GitHub se actualiza y Cloudflare publica automaticamente.

## Variables obligatorias

En Cloudflare Pages > Settings > Environment variables agrega:

- `SESSION_SECRET`: texto largo y secreto, por ejemplo 40 caracteres o mas.
- `USERS_JSON`: JSON con usuarios y hashes.

Ejemplo:

```json
{
  "users": [
    {
      "username": "admin",
      "name": "Administrador",
      "roles": ["admin"],
      "passwordHash": "PEGA_AQUI_HASH_GENERADO"
    },
    {
      "username": "logistica",
      "name": "Encargado Logistica",
      "roles": ["logistica"],
      "passwordHash": "PEGA_AQUI_HASH_GENERADO"
    }
  ]
}
```

Para generar `passwordHash`, ejecuta:

```bat
generar_hash_password.bat
```

## Proteccion completa de dashboards

Este hub protege los botones y valida permisos antes de redirigir. Para seguridad completa, protege tambien cada dashboard destino con Cloudflare Access, porque si un dashboard destino sigue publico, alguien podria abrirlo con la URL directa.
