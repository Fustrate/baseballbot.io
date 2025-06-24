import { cva, type VariantProps } from 'class-variance-authority';

import { cn } from '@/utilities';

const variants = cva(
  ['inline-flex items-center justify-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset'],
  {
    variants: {
      color: {
        gray: ['bg-slate-100 text-slate-600 ring-slate-300/50'],
        red: ['bg-red-100 text-red-700 ring-red-300/50'],
        orange: ['bg-orange-100 text-orange-800 ring-orange-300/50'],
        yellow: ['bg-yellow-100 text-yellow-800 ring-yellow-300/50'],
        green: ['bg-green-100 text-green-700 ring-green-300/50'],
        blue: ['bg-blue-100 text-blue-700 ring-blue-300/50'],
        indigo: ['bg-indigo-100 text-indigo-700 ring-indigo-300/50'],
        purple: ['bg-purple-100 text-purple-700 ring-purple-300/50'],
        pink: ['bg-pink-100 text-pink-700 ring-pink-300/50'],
        black: ['bg-slate-700 text-slate-200 ring-slate-900/50'],

        // gray: ['bg-gray-50 text-gray-600 ring-gray-500/10'],
        // red: ['bg-red-50 text-red-700 ring-red-600/10'],
        // yellow: ['bg-yellow-50 text-yellow-800 ring-yellow-600/20'],
        // green: ['bg-green-50 text-green-700 ring-green-600/20'],
        // blue: ['bg-blue-50 text-blue-700 ring-blue-700/10'],
        // indigo: ['bg-indigo-50 text-indigo-700 ring-indigo-700/10'],
        // purple: ['bg-purple-50 text-purple-700 ring-purple-700/10'],
        // pink: ['bg-pink-50 text-pink-700 ring-pink-700/10'],
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

  delete props.className;

  return (
    <span className={cn(variants({ color }), className)} {...rest}>
      {props.children}
    </span>
  );
}
