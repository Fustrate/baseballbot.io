import type { PropsWithChildren } from 'react';

export default function Main({ children }: PropsWithChildren) {
  return (
    <main>
      <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">{children}</div>
    </main>
  );
}
