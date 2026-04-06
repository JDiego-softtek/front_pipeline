'use client';

import { cn } from '@/utils/cn';
import { cva, VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  [
    'flex w-full items-center justify-center self-stretch gap-sm cursor-pointer text-base-white',
    'px-xl py-2 text-md leading-md font-semibold transition-all duration-150 ease-in-out',
  ],
  {
    variants: {
      variant: {
        primary: [
          'disabled:border disabled:bg-gray-100 disabled:cursor-not-allowed disabled:opacity-100',
          'disabled:border-gray-200 text-base-white disabled:text-gray-400',
          'rounded-full border-2 bg-brand-600 shadow-xs hover:opacity-95 active:opacity-90 border-gray-300',
        ],
        error: 'bg-error-600 disabled:opacity-60',
      },
    },
  },
);

// type ButtonVariant = 'primary';
type ButtonType = 'button' | 'submit' | 'reset';

type ButtonProps = VariantProps<typeof buttonVariants> & {
  onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  type?: ButtonType;
  disabled?: boolean;
  className?: string;
  children?: React.ReactNode;
};

export default function Button({
  className,
  onClick,
  type = 'button',
  disabled = false,
  variant = 'primary',
  children,
}: ButtonProps) {
  const classes = cn(buttonVariants({ variant }), className);

  return (
    <button
      className={classes}
      onClick={onClick}
      type={type}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
