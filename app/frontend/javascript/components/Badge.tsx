import { cva, type VariantProps } from 'class-variance-authority';

import { cn } from '@/utilities';

const variants = cva(
  ['inline-flex items-center justify-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset'],
  {
    variants: {
      color: {
        gray: [
          'bg-slate-100 text-slate-600 ring-slate-300/50 dark:bg-gray-400/10 dark:text-gray-400 dark:ring-gray-400/20',
        ],
        red: ['bg-red-100 text-red-700 ring-red-300/50 dark:bg-red-400/10 dark:text-red-400 dark:ring-red-400/20'],
        orange: [
          'bg-orange-100 text-orange-800 ring-orange-300/50 dark:bg-orange-400/10 dark:text-orange-400 dark:ring-orange-400/20',
        ],
        yellow: [
          'bg-yellow-100 text-yellow-800 ring-yellow-300/50 dark:bg-yellow-400/10 dark:text-yellow-500 dark:ring-yellow-400/20',
        ],
        green: [
          'bg-green-100 text-green-700 ring-green-300/50 dark:bg-green-500/10 dark:text-green-400 dark:ring-green-500/20',
        ],
        blue: [
          'bg-blue-100 text-blue-700 ring-blue-300/50 dark:bg-blue-400/10 dark:text-blue-400 dark:ring-blue-400/30',
        ],
        indigo: [
          'bg-indigo-100 text-indigo-700 ring-indigo-300/50 dark:bg-indigo-400/10 dark:text-indigo-400 dark:ring-indigo-400/30',
        ],
        purple: [
          'bg-purple-100 text-purple-700 ring-purple-300/50 dark:bg-purple-400/10 dark:text-purple-400 dark:ring-purple-400/30',
        ],
        pink: [
          'bg-pink-100 text-pink-700 ring-pink-300/50 dark:bg-pink-400/10 dark:text-pink-400 dark:ring-pink-400/20',
        ],
      },
    },
    defaultVariants: {
      color: 'gray',
    },
  },
);

type LabelVariantProps = VariantProps<typeof variants>;
export type LabelColor = LabelVariantProps['color'];

interface LabelProps
  extends Omit<
      React.DetailedHTMLProps<React.HTMLAttributes<HTMLSpanElement>, HTMLSpanElement>,
      'disabled' | 'ref' | 'color'
    >,
    LabelVariantProps {}

export default function Label(props: LabelProps) {
  const { className, color, ...rest } = props;

  return (
    <span className={cn(variants({ color }), className)} {...rest}>
      {props.children}
    </span>
  );
}
