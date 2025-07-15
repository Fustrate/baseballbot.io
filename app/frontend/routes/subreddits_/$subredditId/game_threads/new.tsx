import { createFileRoute } from '@tanstack/react-router';
import { Text } from '@/catalyst/text';

export const Route = createFileRoute('/subreddits_/$subredditId/game_threads/new')({
  component: RouteComponent,
  loader: async ({ params }) => {
    const { subredditId } = params;

    return { subredditId };
  },
});

function RouteComponent() {
  return <Text>Hello "/subreddits/$subredditId/game_threads/new"!</Text>;
}
