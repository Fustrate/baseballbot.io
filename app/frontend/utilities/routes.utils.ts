export type RequiredParameter = string | number;
export type OptionalParameter = string | number | null;
export type AnyParameter = string | number | string[] | number[] | undefined;

export type RouteFormat = 'json' | 'html' | 'csv' | 'xlsx' | 'pdf' | 'zip' | 'text';

// TODO: Use RouteFormat
export interface RouteOptions {
  [s: string]: AnyParameter;
  format?: string;
}

export function buildRoute(spec: string, options: Record<string, AnyParameter>) {
  let path = spec;
  const parameters = new URLSearchParams();

  Object.entries(options).forEach(([key, value]) => {
    if (path.includes(`:${key}`)) {
      path = path.replace(`:${key}`, String(value));
    } else if (Array.isArray(value)) {
      value.forEach((val: string | number) => {
        parameters.append(`${key}[]`, String(val));
      });
    } else if (value != null) {
      parameters.append(key, String(value));
    }
  });

  path = path.replace(/\(([^)]+)\)/gi, (match, p1: string) => (match.includes(':') ? '' : p1));

  // We can't use paramters.size because it was added in iOS 17
  return [path, String(parameters)].filter(Boolean).join('?');
}
