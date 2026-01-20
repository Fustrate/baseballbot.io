import { createFileRoute } from '@tanstack/react-router';
import { fetchSubreddit } from '@/api/subreddits';
import { ButtonLink } from '@/catalyst/button';
import { Heading } from '@/catalyst/heading';
import { Text } from '@/catalyst/text';
import { useAuth } from '@/hooks/useAuth';

export const Route = createFileRoute('/subreddits/$subredditId')({
  component: RouteComponent,
  loader: async ({ params }) => {
    const subreddit = await fetchSubreddit(params.subredditId);

    return { subreddit };
  },
});

function RouteComponent() {
  const { subreddit } = Route.useLoaderData();
  const { isLoggedIn, user } = useAuth();

  const isModerator = isLoggedIn && user?.subreddits.includes(subreddit.id);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex w-full flex-wrap items-end justify-between gap-4 border-zinc-950/10 border-b pb-6 dark:border-white/10">
        <Heading>/r/{subreddit.name}</Heading>
        {isModerator && <EditButton subredditId={subreddit.name} />}
      </div>

      <WelcomeMessage subreddit={subreddit} isModerator={isModerator} />
    </div>
  );
}

function WelcomeMessage({
  subreddit,
  isModerator,
}: {
  subreddit: { id: number; name: string };
  isModerator?: boolean;
}) {
  if (isModerator) {
    return <Text>You are logged in as a moderator of this subreddit.</Text>;
  }

  return <Text>Hello {subreddit.name}!</Text>;
}

function EditButton({ subredditId }: { subredditId: string }) {
  return (
    <ButtonLink
      style="outline"
      to="/subreddits/$subredditId/edit"
      params={{ subredditId }}
      className="inline-flex items-center gap-1"
    >
      <i className="fas fa-pencil" />
      Edit
    </ButtonLink>
  );
}
