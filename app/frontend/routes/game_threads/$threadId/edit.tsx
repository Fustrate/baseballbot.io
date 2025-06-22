import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/game_threads/$threadId/edit')({
  component: RouteComponent,
  loader: async ({ params }) => {
    const { threadId } = params;

    return { threadId };
  },
});

function RouteComponent() {
  return <div>Hello "/game_threads/$threadId/edit"!</div>;
}
