const SESSION_COOKIE = 'gic_session';
const SESSION_TTL_SECONDS = 60 * 60 * 8;

export const MODULES = {
  vias: {
    name: 'Dashboard Vias',
    url: 'https://dashboard-vias.pages.dev/',
    roles: ['vias', 'admin']
  },
  'santa-clara': {
    name: 'Dashboard Santa Clara',
    url: 'https://dashboard-staclara-web.pages.dev/',
    roles: ['santa-clara', 'admin']
  },
  logistica: {
    name: 'Dashboard Logistica',
    url: 'https://dashboard-logistic.pages.dev/',
    roles: ['logistica', 'admin']
  },
  montacargas: {
    name: 'Dashboard Montacargas',
    url: 'https://dashboard-mtclogist.pages.dev/',
    roles: ['montacargas', 'logistica', 'admin']
  }
};

const encoder = new TextEncoder();

export function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store'
    }
  });
}

export function redirect(location, status = 302) {
  return new Response(null, {
    status,
    headers: {
      Location: location,
      'Cache-Control': 'no-store'
    }
  });
}

export function isSafeNext(value) {
  return typeof value === 'string' && value.startsWith('/') && !value.startsWith('//');
}

export function loadUsers(env) {
  if (!env.USERS_JSON) {
    throw new Error('Falta configurar USERS_JSON en Cloudflare Pages.');
  }

  const parsed = JSON.parse(env.USERS_JSON);
  if (!Array.isArray(parsed.users)) {
    throw new Error('USERS_JSON debe tener una propiedad users.');
  }

  return parsed.users;
}

export function findUser(users, username) {
  const normalized = String(username || '').trim().toLowerCase();
  return users.find((user) => String(user.username || '').toLowerCase() === normalized);
}

export async function verifyPassword(password, storedHash) {
  const [scheme, iterationsText, saltB64, hashB64] = String(storedHash || '').split('$');
  if (scheme !== 'pbkdf2-sha256') return false;

  const iterations = Number(iterationsText);
  if (!Number.isInteger(iterations) || iterations < 100000) return false;

  const salt = base64ToBytes(saltB64);
  const expected = base64ToBytes(hashB64);
  const keyMaterial = await crypto.subtle.importKey('raw', encoder.encode(password), 'PBKDF2', false, ['deriveBits']);
  const derivedBits = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', hash: 'SHA-256', salt, iterations },
    keyMaterial,
    expected.byteLength * 8
  );

  return constantTimeEqual(new Uint8Array(derivedBits), expected);
}

export async function createSession(user, env) {
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    sub: user.username,
    name: user.name || user.username,
    roles: Array.isArray(user.roles) ? user.roles : [],
    iat: now,
    exp: now + SESSION_TTL_SECONDS
  };
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));
  const signature = await sign(encodedPayload, env.SESSION_SECRET);
  return `${encodedPayload}.${signature}`;
}

export async function readSession(request, env) {
  const cookie = request.headers.get('Cookie') || '';
  const match = cookie.match(new RegExp(`${SESSION_COOKIE}=([^;]+)`));
  if (!match) return null;

  const [encodedPayload, signature] = match[1].split('.');
  if (!encodedPayload || !signature) return null;

  const expected = await sign(encodedPayload, env.SESSION_SECRET);
  if (!constantTimeEqual(encoder.encode(signature), encoder.encode(expected))) return null;

  const payload = JSON.parse(base64UrlDecode(encodedPayload));
  if (!payload.exp || payload.exp < Math.floor(Date.now() / 1000)) return null;
  return payload;
}

export function sessionCookie(token) {
  return `${SESSION_COOKIE}=${token}; Path=/; Max-Age=${SESSION_TTL_SECONDS}; HttpOnly; Secure; SameSite=Lax`;
}

export function clearSessionCookie() {
  return `${SESSION_COOKIE}=; Path=/; Max-Age=0; HttpOnly; Secure; SameSite=Lax`;
}

export function canAccess(session, moduleConfig) {
  const roles = Array.isArray(session?.roles) ? session.roles : [];
  return moduleConfig.roles.some((role) => roles.includes(role));
}

async function sign(value, secret) {
  if (!secret || secret.length < 24) {
    throw new Error('SESSION_SECRET debe existir y tener minimo 24 caracteres.');
  }

  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  const signature = await crypto.subtle.sign('HMAC', key, encoder.encode(value));
  return bytesToBase64Url(new Uint8Array(signature));
}

function base64UrlEncode(value) {
  return bytesToBase64Url(encoder.encode(value));
}

function base64UrlDecode(value) {
  const bytes = base64ToBytes(value.replace(/-/g, '+').replace(/_/g, '/'));
  return new TextDecoder().decode(bytes);
}

function bytesToBase64Url(bytes) {
  let binary = '';
  bytes.forEach((byte) => {
    binary += String.fromCharCode(byte);
  });
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
}

function base64ToBytes(value) {
  const padded = value.padEnd(value.length + ((4 - (value.length % 4)) % 4), '=');
  const binary = atob(padded);
  const bytes = new Uint8Array(binary.length);
  for (let index = 0; index < binary.length; index += 1) {
    bytes[index] = binary.charCodeAt(index);
  }
  return bytes;
}

function constantTimeEqual(a, b) {
  if (a.byteLength !== b.byteLength) return false;
  let diff = 0;
  for (let index = 0; index < a.byteLength; index += 1) {
    diff |= a[index] ^ b[index];
  }
  return diff === 0;
}
