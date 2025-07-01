import * as Headless from '@headlessui/react';
import { type LinkComponentProps, Link as ReactRouterLink } from '@tanstack/react-router';
import { forwardRef, type default as React } from 'react';
import { cn } from '@/utilities';

const linkClasses = 'text-sky-600 hover:text-sky-900 dark:hover:text-sky-300';

export const Link = forwardRef(function Link(
  props: LinkComponentProps & React.ComponentPropsWithoutRef<'a'> & { inline?: boolean },
  ref: React.ForwardedRef<HTMLAnchorElement>,
) {
  const { inline, className, ...rest } = props;

  return (
    <Headless.DataInteractive>
      <ReactRouterLink className={cn(inline && linkClasses, className)} {...rest} ref={ref} />
    </Headless.DataInteractive>
  );
});
