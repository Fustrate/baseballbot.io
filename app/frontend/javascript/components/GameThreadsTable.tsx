import { toHumanDate } from '@fustrate/rails/utilities';
import { DateTime } from 'luxon';
import type { GameThread } from '@/api/gameThreads';
import { Badge } from '@/catalyst/badge';
import { Link } from '@/catalyst/link';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/catalyst/table';

function StatusBadge({ gameThread }: { gameThread: GameThread }) {
  const { postAt, startsAt, status } = gameThread;

  if (postAt < DateTime.now() && status === 'Future') {
    return (
      <Badge color="red" className="w-full">
        Error
      </Badge>
    );
  }

  if (startsAt < DateTime.now() && status === 'Posted') {
    return (
      <Badge color="green" className="w-full">
        Live
      </Badge>
    );
  }

  return <Badge className="w-full">{status}</Badge>;
}

interface GameThreadsTableProps {
  gameThreads: GameThread[];
  showSubreddit?: boolean;
}

export default function GameThreadsTable({ gameThreads, showSubreddit }: GameThreadsTableProps) {
  return (
    <Table dense className="[--gutter:--spacing(6)] sm:[--gutter:--spacing(8)]">
      <TableHead>
        <TableRow>
          <TableHeader>PK</TableHeader>
          <TableHeader>Title</TableHeader>
          {showSubreddit !== false && <TableHeader>Subreddit</TableHeader>}
          <TableHeader className="hidden lg:table-cell">Starts At</TableHeader>
          <TableHeader className="hidden lg:table-cell">Post At</TableHeader>
          <TableHeader>Status</TableHeader>
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
              {gameThread.postId ? (
                <Link inline href={`//redd.it/${gameThread.postId}`}>
                  {gameThread.title}
                </Link>
              ) : (
                <span>{gameThread.title}</span>
              )}
              <div className="mt-1 flex items-center gap-1 lg:hidden">
                <Badge color="zinc">Starts @ {gameThread.startsAt.toFormat('t')}</Badge>
                <Badge color="zinc">
                  Post @{' '}
                  {gameThread.postAt.hasSame(gameThread.startsAt, 'day')
                    ? gameThread.postAt.toFormat('t')
                    : toHumanDate(gameThread.postAt, true)}
                </Badge>
              </div>
            </TableCell>
            {showSubreddit !== false && (
              <TableCell>
                <Link inline to="/subreddits/$subredditId" params={{ subredditId: gameThread.subreddit.name }}>
                  {gameThread.subreddit.name}
                </Link>
              </TableCell>
            )}
            <TableCell className="hidden whitespace-nowrap lg:table-cell">
              {gameThread.startsAt.toFormat('t')}
            </TableCell>
            <TableCell className="hidden whitespace-nowrap lg:table-cell">
              {gameThread.postAt.hasSame(gameThread.startsAt, 'day')
                ? gameThread.postAt.toFormat('t')
                : toHumanDate(gameThread.postAt, true)}
            </TableCell>
            <TableCell>
              <StatusBadge gameThread={gameThread} />
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
