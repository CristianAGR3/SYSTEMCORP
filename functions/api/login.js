import {
  createSession,
  findUser,
  isSafeNext,
  json,
  loadUsers,
  sessionCookie,
  verifyPassword
} from '../_shared/auth.js';

export async function onRequestPost({ request, env }) {
  try {
    const body = await request.json();
    const users = loadUsers(env);
    const user = findUser(users, body.username);

    if (!user || !(await verifyPassword(body.password || '', user.passwordHash))) {
      return json({ error: 'Usuario o contrasena incorrectos.' }, 401);
    }

    const token = await createSession(user, env);
    const next = isSafeNext(body.next) ? body.next : '/';

    return new Response(JSON.stringify({ ok: true, next }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Set-Cookie': sessionCookie(token),
        'Cache-Control': 'no-store'
      }
    });
  } catch (error) {
    return json({ error: error.message || 'Error de autenticacion.' }, 500);
  }
}

export function onRequestGet() {
  return json({ error: 'Metodo no permitido.' }, 405);
}
