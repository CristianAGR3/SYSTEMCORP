const form = document.getElementById('loginForm');
const message = document.getElementById('message');
const nextInput = document.getElementById('next');

const params = new URLSearchParams(window.location.search);
const requestedNext = params.get('next') || '/';

function isSafeNext(value) {
  return typeof value === 'string' && value.startsWith('/') && !value.startsWith('//');
}

nextInput.value = isSafeNext(requestedNext) ? requestedNext : '/';

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  message.textContent = '';

  const button = form.querySelector('button');
  button.disabled = true;

  try {
    const response = await fetch('/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: form.username.value.trim(),
        password: form.password.value,
        next: nextInput.value
      })
    });

    const result = await response.json().catch(() => ({}));

    if (!response.ok) {
      message.textContent = result.error || 'No se pudo iniciar sesion.';
      button.disabled = false;
      return;
    }

    window.location.href = result.next || nextInput.value || '/';
  } catch (error) {
    message.textContent = 'No hay conexion con el servicio de autenticacion.';
    button.disabled = false;
  }
});
