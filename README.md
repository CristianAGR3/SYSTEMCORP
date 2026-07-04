# GIC CONTROL 360

Hub central para dashboards de AGR3 con acceso por usuario, sesion firmada y permisos por modulo.

## Como se publica

1. El repositorio se conecta a Cloudflare Pages.
2. Cloudflare Pages publica la rama `main`.
3. Cada `git push` actualiza automaticamente el sitio.

En Windows puedes usar:

```bat
subir_main_github_cloudflare.bat
```

Ese archivo inicializa Git si hace falta, configura el remoto `https://github.com/CristianAGR3/SYSTEMCORP.git`, crea el commit, sube `main` a GitHub y permite ejecutar deploy directo con Cloudflare Wrangler si Node.js esta instalado.

## Seguridad

Este proyecto incluye login server-side con Cloudflare Pages Functions:

- `POST /api/login` valida usuario y contrasena.
- La sesion se guarda en una cookie `HttpOnly`, `Secure` y firmada.
- Las rutas `/go/vias`, `/go/santa-clara`, `/go/logistica` y `/go/montacargas` validan roles antes de redirigir.

Importante: para proteccion completa, los dashboards destino tambien deben protegerse con Cloudflare Access o moverse detras del mismo sistema. Si los dashboards siguen publicos, alguien con la URL directa podria abrirlos sin pasar por este hub.

## Variables requeridas en Cloudflare Pages

Configura estas variables en Cloudflare Pages > Settings > Environment variables:

- `SESSION_SECRET`: texto secreto largo, minimo 24 caracteres.
- `USERS_JSON`: JSON con usuarios, roles y hashes PBKDF2. Usa `USERS_JSON.example.json` como formato.

## Roles actuales

- `admin`: acceso a todos los dashboards.
- `vias`: acceso a Dashboard Vias.
- `santa-clara`: acceso a Dashboard Santa Clara.
- `logistica`: acceso a Dashboard Logistica y Montacargas.
- `montacargas`: acceso solo a Dashboard Montacargas.

## Generar hashes de contrasena

Puedes generar hashes PBKDF2 SHA-256 con este comando de Node.js:

```powershell
node scripts/hash-password.mjs "TU_CONTRASENA"
```

El resultado se pega como `passwordHash` dentro de `USERS_JSON`.

Tambien puedes usar:

```bat
generar_hash_password.bat
```

Lee `configurar_cloudflare.md` para conectar GitHub con Cloudflare Pages paso a paso.
