export type RequiredParameter = string | number | { id: number } | { toParam?: number | string };
export type OptionalParameter = string | number | null | undefined;
export type AnyParameter = RequiredParameter | string[] | number[] | null | undefined;

export type RouteFormat = 'json' | 'html' | 'csv' | 'xlsx' | 'pdf' | 'zip' | 'text';

// TODO: Use RouteFormat
export interface RouteOptions {
  [s: string]: AnyParameter;
  format?: string;
}

function stringifyValue(value: AnyParameter): string {
  if (value == null) {
    return '';
  }

  if (typeof value === 'object') {
    // Allow some records to use an alternate ID in their URL, e.g. an email address
    if ('toParam' in value) {
      return String(value.toParam);
    }

    // Raw JSON data doesn't have a toParam method
    if ('id' in value) {
      return String(value.id);
    }

    throw new Error('route parameter objects must have an id or toParam attribute');
  }

  return String(value);
}

export function buildRoute(spec: string, options: Record<string, AnyParameter>) {
  let path = spec;
  const parameters = new URLSearchParams();

  for (const [key, value] of Object.entries(options)) {
    if (path.includes(`:${key}`)) {
      path = path.replace(`:${key}`, stringifyValue(value));
    } else if (Array.isArray(value)) {
      for (const val of value) {
        parameters.append(`${key}[]`, String(val));
      }
    } else if (value != null) {
      parameters.append(key, stringifyValue(value));
    }
  }

  path = path.replace(/\(([^)]+)\)/gi, (match, p1: string) => (match.includes(':') ? '' : p1));

  // We can't use paramters.size because it was added in iOS 17
  return [path, String(parameters)].filter(Boolean).join('?');
}
