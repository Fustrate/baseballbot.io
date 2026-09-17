function getCsrfToken(): string {
  return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') ?? '';
}

function fetchJSON(input: RequestInfo | URL, init: RequestInit = {}): Promise<Response> {
  const headers = new Headers(init.headers);
  headers.set('X-CSRF-Token', getCsrfToken());
  headers.set('Content-Type', 'application/json');

  return fetch(input, {
    ...init,
    headers,
  });
}

export function getJSON(input: RequestInfo | URL, init: RequestInit = {}) {
  return fetchJSON(input, { ...init, method: 'GET' });
}

export function patchJSON(input: RequestInfo | URL, init: RequestInit = {}) {
  return fetchJSON(input, { ...init, method: 'PATCH' });
}

export function postJSON(input: RequestInfo | URL, init: RequestInit = {}) {
  return fetchJSON(input, { ...init, method: 'POST' });
}
