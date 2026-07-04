import { clearSessionCookie, redirect } from '../_shared/auth.js';

export function onRequest() {
  return new Response(null, {
    status: 302,
    headers: {
      Location: '/',
      'Set-Cookie': clearSessionCookie(),
      'Cache-Control': 'no-store'
    }
  });
}
