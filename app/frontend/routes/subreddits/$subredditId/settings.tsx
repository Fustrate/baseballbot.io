import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/subreddits/$subredditId/settings')({
  component: RouteComponent,
  loader: async ({ params }) => {
    const { subredditId } = params;

    return { subredditId };
  },
});

function RouteComponent() {
  return <div>Hello "/subreddits/$subredditId/settings"!</div>;
}
