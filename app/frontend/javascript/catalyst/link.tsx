import * as Headless from '@headlessui/react';
import { type LinkComponentProps, Link as ReactRouterLink } from '@tanstack/react-router';
import { forwardRef, type default as React } from 'react';
import { cn } from '@/utilities';

const linkClasses = 'text-sky-600 hover:text-sky-900';

export const Link = forwardRef(function Link(
  props: LinkComponentProps & React.ComponentPropsWithoutRef<'a'>,
  ref: React.ForwardedRef<HTMLAnchorElement>,
) {
  const { className, ...rest } = props;

  return (
    <Headless.DataInteractive>
      <ReactRouterLink className={cn(className, linkClasses)} {...rest} ref={ref} />
    </Headless.DataInteractive>
  );
});
