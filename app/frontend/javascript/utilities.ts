export function postAtFormat(postAt?: string): string {
  if (!postAt) {
    return '3 Hours Pregame';
  }

  if (/^-?\d{1,2}$/.test(postAt)) {
    return `${Math.abs(Number.parseInt(postAt, 10))} Hours Pregame`;
  }

  if (/(1[0-2]|\d)(:\d\d|) ?(am|pm)/i.test(postAt)) {
    return `at ${postAt}`;
  }

  // Bad format, default back to 3 hours pregame
  return '3 Hours Pregame';
}
