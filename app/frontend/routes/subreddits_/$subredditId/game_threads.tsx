import { createFileRoute } from '@tanstack/react-router';
import { fetchSubreddit } from '@/api/subreddits';
import { Text } from '@/catalyst/text';

export const Route = createFileRoute('/subreddits_/$subredditId/game_threads')({
  component: RouteComponent,
  loader: async ({ params }) => {
    const subreddit = await fetchSubreddit(params.subredditId);

    return { subreddit };
  },
  head: ({ params }) => ({
    meta: [{ title: `Baseballbot - /r/${params.subredditId} - Game Threads` }],
  }),
});

function RouteComponent() {
  return <Text>Hello "/subreddits/$subredditId/game_threads"!</Text>;
}
