import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/gameday')({
  component: RouteComponent,
});

function RouteComponent() {
  return <div>Hello "/gameday"!</div>;
}
