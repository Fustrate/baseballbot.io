import { createFileRoute } from '@tanstack/react-router';

import Main from '@/components/Main';
import PageHeader from '@/components/PageHeader';

export const Route = createFileRoute('/')({
  component: RouteComponent,
  head: () => ({
    meta: [{ title: 'Baseballbot.io' }],
  }),
});

function RouteComponent() {
  return (
    <>
      <PageHeader>Home</PageHeader>

      <Main />
    </>
  );
}
