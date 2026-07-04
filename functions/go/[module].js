import { canAccess, MODULES, readSession, redirect } from '../_shared/auth.js';

export async function onRequestGet({ params, request, env }) {
  const moduleConfig = MODULES[params.module];
  if (!moduleConfig) {
    return new Response('Modulo no encontrado.', { status: 404 });
  }

  const session = await readSession(request, env);
  if (!session) {
    return redirect(`/login.html?next=/go/${encodeURIComponent(params.module)}`);
  }

  if (!canAccess(session, moduleConfig)) {
    return new Response('Acceso denegado para este dashboard.', {
      status: 403,
      headers: { 'Cache-Control': 'no-store' }
    });
  }

  return redirect(moduleConfig.url);
}
