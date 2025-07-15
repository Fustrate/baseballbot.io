import { createFileRoute } from '@tanstack/react-router';
import { Text } from '@/catalyst/text';

export const Route = createFileRoute('/subreddits_/$subredditId/settings')({
  component: RouteComponent,
  loader: async ({ params }) => {
    const { subredditId } = params;

    return { subredditId };
  },
});

function RouteComponent() {
  return <Text>Hello "/subreddits/$subredditId/settings"!</Text>;
}
