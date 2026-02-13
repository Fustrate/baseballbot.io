import { toHumanDate } from '@fustrate/rails/utilities';
import { DateTime } from 'luxon';
import type { ReactNode } from 'react';
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
  return subreddit.options?.gameThreads?.title ?? 'Game Thread';
}

function postAt(gameThread: GameThread) {
  if (gameThread.status === 'External') {
    return;
  }

  return gameThread.postAt.hasSame(gameThread.startsAt, 'day')
    ? gameThread.postAt.toFormat('t')
    : toHumanDate(gameThread.postAt, true);
}

// Date/time interpolations can be run without having to load MLB data
function interpolationText(target: string, gameThread: GameThread) {
  switch (target) {
    case '{{start_time_et}}':
      return gameThread.startsAt.setZone('America/New_York').toLocaleString(DateTime.TIME_SIMPLE);
    case '{{start_time}}':
      return gameThread.startsAt.setZone(gameThread.subreddit.options.timezone).toLocaleString(DateTime.TIME_SIMPLE);
    case '{{day}}':
      return gameThread.startsAt.toFormat('d');
    case '{{day_of_week}}':
      return gameThread.startsAt.toFormat('cccc');
    case '{{short_day_of_week}}':
      return gameThread.startsAt.toFormat('ccc');
    case '{{month}}':
      return gameThread.startsAt.month;
    case '{{month_name}}':
      return gameThread.startsAt.toFormat('LLLL');
    case '{{short_month}}':
      return gameThread.startsAt.toFormat('LLL');
    case '{{short_year}}':
      return gameThread.startsAt.toFormat('yy');
    case '{{year}}':
      return gameThread.startsAt.year;
    default:
      return (
        <Badge color="zinc" key={target}>
          {target.slice(2, -2)}
        </Badge>
      );
  }
}

function highlightInterpolations(gameThread: GameThread) {
  let input = gameThread.title ?? defaultTitle(gameThread.subreddit);
  const output: (string | ReactNode)[] = [];
  let startIndex = input.indexOf('{{');

  while (startIndex > -1) {
    output.push(input.slice(0, startIndex));

    const endIndex = input.indexOf('}}', startIndex + 2);

    if (endIndex > -1) {
      output.push(interpolationText(input.slice(startIndex, endIndex + 2), gameThread));

      input = input.slice(endIndex + 2);

      startIndex = input.indexOf('{{');
    } else {
      startIndex = -1;
    }
  }

  return <div>{[...output, input]}</div>;
}

function GameThreadRow({ gameThread, showSubreddit }: { gameThread: GameThread; showSubreddit?: boolean }) {
  return (
    <TableRow key={gameThread.id}>
      <TableCell>
        <Link inline href={`https://www.mlb.com/gameday/${gameThread.gamePk}`}>
          {gameThread.gamePk}
        </Link>
      </TableCell>
      <TableCell className="whitespace-normal">
        <div className="flex flex-col gap-1.5">
          {gameThread.postId ? (
            <Link inline href={`https://redd.it/${gameThread.postId}`}>
              {gameThread.title}
            </Link>
          ) : (
            highlightInterpolations(gameThread)
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
      <TableCell className="hidden whitespace-nowrap lg:table-cell">{gameThread.startsAt.toFormat('t')}</TableCell>
      <TableCell className="hidden whitespace-nowrap lg:table-cell">{postAt(gameThread)}</TableCell>
      <TableCell className="hidden lg:table-cell">
        <StatusBadge gameThread={gameThread} className="w-full" />
      </TableCell>
    </TableRow>
  );
}

function EmptyTableRow() {
  return (
    <TableRow key="empty">
      <TableCell colSpan={10} className="text-center">
        There are no game threads scheduled on this date.
      </TableCell>
    </TableRow>
  );
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
          <GameThreadRow key={gameThread.id} gameThread={gameThread} showSubreddit={showSubreddit} />
        ))}
        {gameThreads.length === 0 && <EmptyTableRow />}
      </TableBody>
    </Table>
  );
}
