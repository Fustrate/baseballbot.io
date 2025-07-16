import { createFileRoute } from '@tanstack/react-router';
import { fetchSubreddit } from '@/api/subreddits';
import { Text } from '@/catalyst/text';

export const Route = createFileRoute('/subreddits/$subredditId')({
  component: RouteComponent,
  loader: async ({ params }) => {
    const subreddit = await fetchSubreddit(params.subredditId);

    return { subreddit };
  },
});

function RouteComponent() {
  const { subreddit } = Route.useLoaderData();

  return <Text>Hello {subreddit.name}!</Text>;
}
