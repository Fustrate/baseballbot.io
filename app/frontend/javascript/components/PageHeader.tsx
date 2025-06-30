import { cva, type VariantProps } from 'class-variance-authority';
import type { ReactNode } from 'react';
import { cn } from '@/utilities';

const variants = cva(['shadow-xs'], {
  variants: {
    color: {
      default: ['bg-white text-slate-900 dark:bg-sky-950 dark:text-slate-100'],
      red: ['bg-rose-200 text-rose-900 dark:bg-rose-950 dark:text-rose-50'],
    },
  },
  defaultVariants: {
    color: 'default',
  },
});

type PageHeaderVariantProps = VariantProps<typeof variants>;
export type PageHeaderColor = PageHeaderVariantProps['color'];

interface PageHeaderProps
  extends Omit<
      React.DetailedHTMLProps<React.HTMLAttributes<HTMLDivElement>, HTMLDivElement>,
      'disabled' | 'ref' | 'color'
    >,
    PageHeaderVariantProps {
  leftButton?: ReactNode;
  rightButton?: ReactNode;
}

export default function PageHeader(props: PageHeaderProps) {
  const { className, color, ...rest } = props;

  return (
    <header className={cn(variants({ color }), className)} {...rest}>
      <div className="mx-auto flex max-w-7xl items-center justify-between px-4 py-4 sm:px-6 lg:px-8">
        {props.leftButton ?? <span />}
        <h1 className="text-center font-semibold text-lg/6">{props.children}</h1>
        {props.rightButton ?? <span />}
      </div>
    </header>
  );
}
