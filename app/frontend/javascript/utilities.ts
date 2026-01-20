import clsx, { type ClassValue } from 'clsx';
import { DateTime } from 'luxon';
import { twMerge } from 'tailwind-merge';

export function postAtFormat(postAt?: string, inTimeZone?: string): string {
  if (!postAt) {
    return '3 Hours Pregame';
  }

  if (/^-?\d{1,2}$/.test(postAt)) {
    return `${Math.abs(Number.parseInt(postAt, 10))} Hours Pregame`;
  }

  // This needs to be converted to the team's time zone for display purposes
  if (/(1[0-2]|\d)(:\d\d|) ?(am|pm)?/i.test(postAt)) {
    return DateTime.fromFormat(postAt, 'h:mm', { zone: 'America/Los_Angeles' })
      .setZone(inTimeZone || 'America/Los_Angeles')
      .toFormat('h:mm a ZZZZ')
      .replace(':00', '');
  }

  // Bad format, default back to 3 hours pregame
  return '3 Hours Pregame';
}

export function cn(...classes: ClassValue[]) {
  return twMerge(clsx(...classes));
}
