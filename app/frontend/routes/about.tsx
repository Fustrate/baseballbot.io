import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/about')({
  component: RouteComponent,
});

function RouteComponent() {
  return (
    <div className="p-2">
      <h3>Hello from About!</h3>
    </div>
  );
}
