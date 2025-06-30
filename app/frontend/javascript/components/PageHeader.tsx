import { cva, type VariantProps } from 'class-variance-authority';

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

type LabelVariantProps = VariantProps<typeof variants>;
export type LabelColor = LabelVariantProps['color'];

interface PageHeaderProps
  extends Omit<
      React.DetailedHTMLProps<React.HTMLAttributes<HTMLSpanElement>, HTMLSpanElement>,
      'disabled' | 'ref' | 'color'
    >,
    LabelVariantProps {}

export default function PageHeader(props: PageHeaderProps) {
  const { className, color, ...rest } = props;

  return (
    <header className={cn(variants({ color }), className)} {...rest}>
      <div className="mx-auto max-w-7xl px-4 py-4 sm:px-6 lg:px-8">
        <h1 className="text-center font-semibold text-lg/6">{props.children}</h1>
      </div>
    </header>
  );
}
