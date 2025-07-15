import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/subreddits_/$subredditId/game_threads/new')({
  component: RouteComponent,
  loader: async ({ params }) => {
    const { subredditId } = params;

    return { subredditId };
  },
});

function RouteComponent() {
  return <div>Hello "/subreddits/$subredditId/game_threads/new"!</div>;
}
