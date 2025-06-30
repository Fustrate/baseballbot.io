import { Link as DefaultLink } from '@tanstack/react-router';

export const linkClasses = 'text-sky-600 hover:text-sky-900 dark:text-sky-300 dark:hover:text-sky-100';

export default function Link(props: React.ComponentProps<typeof DefaultLink>) {
  return <DefaultLink {...props} className={linkClasses} />;
}
