import { createFileRoute } from '@tanstack/react-router';

import { fetchSubreddits, type Subreddit } from '@/api/subreddits';
import { Heading } from '@/catalyst/heading';
import { Link } from '@/catalyst/link';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/catalyst/table';
import { useAuth } from '@/hooks/useAuth';
import { postAtFormat } from '@/utilities';

export const Route = createFileRoute('/subreddits/')({
  component: RouteComponent,
  loader: fetchSubreddits,
  head: () => ({
    meta: [{ title: 'Subreddits' }],
  }),
});

function RouteComponent() {
  const subreddits = Route.useLoaderData();
  const { isLoggedIn, user } = useAuth();

  const moderatedSubIds = user?.subreddits || [];

  const sortedSubreddits = [...subreddits].sort((a, b) => {
    const aModerated = moderatedSubIds.includes(a.id);
    const bModerated = moderatedSubIds.includes(b.id);

    if (aModerated !== bModerated) {
      return aModerated ? -1 : 1;
    }

    return a.name.localeCompare(b.name);
  });

  return (
    <>
      <div className="flex w-full flex-wrap items-end justify-between gap-4 border-zinc-950/10 border-b pb-6 dark:border-white/10">
        <Heading>Subreddits</Heading>
      </div>

      <Table dense className="[--gutter:--spacing(6)] sm:[--gutter:--spacing(8)]">
        <TableHead>
          <TableRow>
            <TableHeader>Name</TableHeader>
            {isLoggedIn && <TableHeader />}
            <TableHeader>Team</TableHeader>
            <TableHeader>Account</TableHeader>
            <TableHeader>Sidebar</TableHeader>
            <TableHeader>Game Threads</TableHeader>
            <TableHeader>Pre Game</TableHeader>
            <TableHeader>Post Game</TableHeader>
            <TableHeader>Off Day</TableHeader>
          </TableRow>
        </TableHead>

        <TableBody>
          {sortedSubreddits.map((subreddit: Subreddit) => (
            <TableRow key={subreddit.id}>
              <TableCell>
                <Link inline to="/subreddits/$subredditId" params={{ subredditId: subreddit.name }}>
                  {subreddit.name}
                </Link>
              </TableCell>
              {isLoggedIn && (
                <TableCell>
                  {moderatedSubIds.includes(subreddit.id) && <i className="fa fa-star" title="Moderator" />}
                </TableCell>
              )}
              <TableCell>{subreddit.abbreviation}</TableCell>
              <TableCell>{subreddit.bot.name}</TableCell>
              <TableCell>{subreddit.options.sidebar?.enabled && <i className="fa fa-check" />}</TableCell>
              <TableCell>
                {subreddit.options.gameThreads?.enabled && postAtFormat(subreddit.options.gameThreads?.postAt)}
              </TableCell>
              <TableCell>
                {subreddit.options.pregame?.enabled && postAtFormat(subreddit.options.pregame?.postAt)}
              </TableCell>
              <TableCell>{subreddit.options.postgame?.enabled && <i className="fa fa-check" />}</TableCell>
              <TableCell>
                {subreddit.options.offDay?.enabled && postAtFormat(subreddit.options.offDay?.postAt)}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </>
  );
}
