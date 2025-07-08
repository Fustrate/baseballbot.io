import { createFileRoute } from '@tanstack/react-router';
import { Heading } from '@/catalyst/heading';

export const Route = createFileRoute('/')({
  component: RouteComponent,
  head: () => ({
    meta: [{ title: 'Baseballbot.io' }],
  }),
});

function RouteComponent() {
  return (
    <div className="flex w-full flex-wrap items-end justify-between gap-4 border-zinc-950/10 border-b pb-6 dark:border-white/10">
      <Heading>Home</Heading>
    </div>
  );
}
