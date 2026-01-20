import { createFileRoute } from '@tanstack/react-router';
import { fetchSubreddit, type Subreddit } from '@/api/subreddits';
import { ButtonLink } from '@/catalyst/button';
import { Heading, Subheading } from '@/catalyst/heading';
import { Text } from '@/catalyst/text';
import { useAuth } from '@/hooks/useAuth';
import { postAtFormat } from '@/utilities';

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

      {/* <WelcomeMessage subreddit={subreddit} isModerator={isModerator} /> */}

      <SubredditOptions subreddit={subreddit} />
    </div>
  );
}

// function WelcomeMessage({
//   subreddit,
//   isModerator,
// }: {
//   subreddit: { id: number; name: string };
//   isModerator?: boolean;
// }) {
//   if (isModerator) {
//     return <Text>You are logged in as a moderator of this subreddit.</Text>;
//   }

//   return <Text>Hello {subreddit.name}!</Text>;
// }

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

function SubredditOptions({ subreddit }: { subreddit: Subreddit }) {
  const { options } = subreddit;

  return (
    <div className="space-y-8">
      <OptionsList label="General Settings">
        <ListItem label="Timezone">{options.timezone}</ListItem>
        <ListItem label="Bot Account">{subreddit.bot.name}</ListItem>
        <ListItem label="Sticky Slot">{options.stickySlot ?? 'Not set'}</ListItem>
      </OptionsList>

      <OptionsList label="Sidebar Updates" enabled={options.sidebar?.enabled} />

      <OptionsList label="Game Threads" enabled={options.gameThreads?.enabled}>
        {options.gameThreads?.enabled && (
          <>
            <ListItem label="Post At">{postAtFormat(options.gameThreads.postAt, options.timezone)}</ListItem>
            <ListItem label="Sticky">{options.gameThreads.sticky === false ? 'No' : 'Yes'}</ListItem>
            <ListItem label="Flair ID">{options.gameThreads.flairId?.default || 'Not set'}</ListItem>
            <ListItem label="Default Title">{options.gameThreads.title.default}</ListItem>
            <ListItem label="Postseason Title">{options.gameThreads.title.postseason || 'Not set'}</ListItem>
            <ListItem label="Sticky Comment">{options.gameThreads.stickyComment || 'Not set'}</ListItem>
          </>
        )}
      </OptionsList>

      <OptionsList label="Pregame Threads" enabled={options.pregame?.enabled}>
        {options.pregame?.enabled && (
          <>
            <ListItem label="Post At">{postAtFormat(options.pregame.postAt, options.timezone)}</ListItem>
            <ListItem label="Sticky">{options.pregame.sticky === false ? 'No' : 'Yes'}</ListItem>
            <ListItem label="Sticky Comment">{options.pregame.stickyComment || 'Not set'}</ListItem>
          </>
        )}
      </OptionsList>

      <OptionsList label="Postgame Threads" enabled={options.postgame?.enabled}>
        {options.postgame?.enabled && (
          <>
            <ListItem label="Sticky">{options.postgame.sticky === false ? 'No' : 'Yes'}</ListItem>
            <ListItem label="Default Title">{options.postgame.title.default}</ListItem>
            <ListItem label="Won Title">{options.postgame.title.won || 'Not set'}</ListItem>
            <ListItem label="Lost Title">{options.postgame.title.lost || 'Not set'}</ListItem>
            <ListItem label="Sticky Comment">{options.postgame.stickyComment || 'Not set'}</ListItem>
          </>
        )}
      </OptionsList>

      <OptionsList label="Off Day Threads" enabled={options.offDay?.enabled}>
        {options.offDay?.enabled && (
          <>
            <ListItem label="Post At">{postAtFormat(options.offDay.postAt, options.timezone)}</ListItem>
            <ListItem label="Sticky">{options.offDay.sticky === false ? 'No' : 'Yes'}</ListItem>
            <ListItem label="Title">{options.offDay.title}</ListItem>
            <ListItem label="Last Run At">{options.offDay.lastRunAt || 'Never'}</ListItem>
            <ListItem label="Sticky Comment">{options.offDay.stickyComment || 'Not set'}</ListItem>
          </>
        )}
      </OptionsList>
    </div>
  );
}

function OptionsList(options: { label: string; children?: React.ReactNode; enabled?: boolean }) {
  return (
    <div className="space-y-4">
      <Subheading>
        {'enabled' in options && <StatusBadge enabled={options.enabled} />} {options.label}
      </Subheading>

      {options.enabled === false && <FeatureDisabled />}
      {options.enabled !== false && (
        <dl className="divide-y divide-zinc-950/10 dark:divide-white/10">{options.children}</dl>
      )}
    </div>
  );
}

function StatusBadge({ enabled }: { enabled?: boolean }) {
  return (
    <span
      className={`mr-2 inline-block size-2 rounded-full ${enabled ? 'bg-green-500' : 'bg-zinc-400 dark:bg-zinc-600'}`}
      title={enabled ? 'Enabled' : 'Disabled'}
    />
  );
}

function ListItem({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="grid grid-cols-[auto_1fr] gap-x-6 gap-y-1 px-0 py-3">
      <dt className="w-43 font-medium text-sm text-zinc-500 dark:text-zinc-400">{label}</dt>
      <dd className="text-sm text-zinc-900 dark:text-white">{children}</dd>
    </div>
  );
}

function FeatureDisabled() {
  return <Text>Feature Disabled</Text>;
}
