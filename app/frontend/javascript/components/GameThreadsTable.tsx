import { toHumanDate } from '@fustrate/rails/utilities';
import { DateTime } from 'luxon';
import type { GameThread } from '@/api/gameThreads';
import type { Subreddit } from '@/api/subreddits';
import { Badge, BadgeButton } from '@/catalyst/badge';
import { Link } from '@/catalyst/link';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/catalyst/table';

function StatusBadge(props: { gameThread: GameThread; className?: string }) {
  const {
    gameThread: { postAt, startsAt, status },
    className,
  } = props;

  if (postAt < DateTime.now() && status === 'Future') {
    return (
      <Badge color="red" className={className}>
        Error
      </Badge>
    );
  }

  if (startsAt < DateTime.now() && status === 'Posted') {
    return (
      <Badge color="green" className={className}>
        Live
      </Badge>
    );
  }

  switch (status) {
    case 'Future':
      return (
        <Badge color="blue" className={className}>
          Future
        </Badge>
      );
    case 'Posted':
      return (
        <Badge color="purple" className={className}>
          Posted
        </Badge>
      );
    case 'Pregame':
      return (
        <Badge color="teal" className={className}>
          Pregame
        </Badge>
      );
    case 'Over':
      return (
        <Badge color="indigo" className={className}>
          Over
        </Badge>
      );
    case 'Removed':
      return (
        <Badge color="amber" className={className}>
          Removed
        </Badge>
      );
    case 'Postponed':
      return (
        <Badge color="yellow" className={className}>
          Postponed
        </Badge>
      );
    case 'External':
      return (
        <Badge color="violet" className={className}>
          External
        </Badge>
      );
    default:
      return <Badge className={className}>{status}</Badge>;
  }
}

interface GameThreadsTableProps {
  gameThreads: GameThread[];
  showSubreddit?: boolean;
}

function defaultTitle(subreddit: Subreddit) {
  return subreddit.options?.gameThreads?.title?.default ?? 'Game Thread';
}

function postAt(gameThread: GameThread) {
  if (gameThread.status === 'External') {
    return;
  }

  return gameThread.postAt.hasSame(gameThread.startsAt, 'day')
    ? gameThread.postAt.toFormat('t')
    : toHumanDate(gameThread.postAt, true);
}

export default function GameThreadsTable({ gameThreads, showSubreddit }: GameThreadsTableProps) {
  return (
    <Table dense className="[--gutter:--spacing(6)] sm:[--gutter:--spacing(8)]">
      <TableHead>
        <TableRow>
          <TableHeader>PK</TableHeader>
          <TableHeader>Title</TableHeader>
          {showSubreddit !== false && <TableHeader className="hidden lg:table-cell">Subreddit</TableHeader>}
          <TableHeader className="hidden lg:table-cell">Starts At</TableHeader>
          <TableHeader className="hidden lg:table-cell">Post At</TableHeader>
          <TableHeader className="hidden lg:table-cell">Status</TableHeader>
        </TableRow>
      </TableHead>

      <TableBody>
        {gameThreads.map((gameThread) => (
          <TableRow key={gameThread.id}>
            <TableCell>
              <Link inline href={`https://www.mlb.com/gameday/${gameThread.gamePk}`}>
                {gameThread.gamePk}
              </Link>
            </TableCell>
            <TableCell className="whitespace-normal">
              <div className="flex flex-col gap-1.5">
                {gameThread.postId ? (
                  <Link inline href={`//redd.it/${gameThread.postId}`}>
                    {gameThread.title}
                  </Link>
                ) : (
                  (gameThread.title ?? defaultTitle(gameThread.subreddit))
                )}
                <BadgeButton href={`/subreddits/${gameThread.subreddit.name}`} className="lg:hidden">
                  {gameThread.subreddit.name}
                </BadgeButton>
                <div className="flex items-center gap-1 lg:hidden">
                  <Badge color="zinc">Starts @ {gameThread.startsAt.toFormat('t')}</Badge>
                  {gameThread.status !== 'External' && <Badge color="zinc">Post @ {postAt(gameThread)}</Badge>}
                  <StatusBadge gameThread={gameThread} />
                </div>
              </div>
            </TableCell>
            {showSubreddit !== false && (
              <TableCell className="hidden lg:table-cell">
                <Link inline to="/subreddits/$subredditId" params={{ subredditId: gameThread.subreddit.name }}>
                  {gameThread.subreddit.name}
                </Link>
              </TableCell>
            )}
            <TableCell className="hidden whitespace-nowrap lg:table-cell">
              {gameThread.startsAt.toFormat('t')}
            </TableCell>
            <TableCell className="hidden whitespace-nowrap lg:table-cell">{postAt(gameThread)}</TableCell>
            <TableCell className="hidden lg:table-cell">
              <StatusBadge gameThread={gameThread} className="w-full" />
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
