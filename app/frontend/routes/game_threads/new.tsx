import { createFileRoute, useNavigate } from '@tanstack/react-router';
import { DateTime } from 'luxon';
import { useState } from 'react';
import { z } from 'zod';
import { fetchGames, type ScheduleGame } from '@/api/games';
import { createGameThread, fetchGameThreads, type GameThread } from '@/api/gameThreads';
import { fetchSubreddits, type Subreddit } from '@/api/subreddits';
import { Button } from '@/catalyst/button';
import { Field, Fieldset, Label } from '@/catalyst/fieldset';
import { Heading } from '@/catalyst/heading';
import { Input } from '@/catalyst/input';
import { Link } from '@/catalyst/link';
import { Select } from '@/catalyst/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/catalyst/table';
import { Text } from '@/catalyst/text';
import { useAuth } from '@/hooks/useAuth';

z.config({ jitless: true });

function adjustPostAt(startTime: DateTime, postAt: string): DateTime {
  if (postAt.startsWith('-')) {
    return startTime.minus({ hour: Number.parseInt(postAt, 10) });
  }

  const [hour, minute] = postAt.split(':').map(Number);

  return startTime.set({ hour, minute });
}

export const Route = createFileRoute('/game_threads/new')({
  validateSearch: z.object({
    date: z.string().optional(),
  }),
  component: RouteComponent,
  loader: async () => {
    const subreddits = await fetchSubreddits();

    return { subreddits };
  },
  head: () => ({
    meta: [{ title: 'New Game Thread' }],
  }),
});

function RouteComponent() {
  const { subreddits } = Route.useLoaderData();
  const search = Route.useSearch();
  const navigate = useNavigate();
  const { isLoggedIn, user } = useAuth();

  const moderatedSubIds = user?.subreddits || [];
  const moderatedSubreddits = subreddits.filter((sub) => moderatedSubIds.includes(sub.id));

  const [selectedSubredditId, setSelectedSubredditId] = useState<string>('');
  const [selectedDate, setSelectedDate] = useState<string>(search.date || DateTime.now().toISODate() || '');
  const [games, setGames] = useState<ScheduleGame[]>([]);
  const [existingThreads, setExistingThreads] = useState<GameThread[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedGame, setSelectedGame] = useState<ScheduleGame | null>(null);
  const [title, setTitle] = useState<string>('');
  const [postAt, setPostAt] = useState<DateTime>();
  const [creating, setCreating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const selectedSubreddit = selectedSubredditId
    ? subreddits.find((s) => s.id.toString() === selectedSubredditId)
    : null;

  const loadGamesForDate = async (date: string) => {
    if (!date || !selectedSubredditId) return;

    setSelectedGame(null);
    setGames([]);
    setExistingThreads([]);
    setError(null);

    setLoading(true);
    try {
      const dateObj = new Date(date);
      const dateTime = DateTime.fromISO(date);

      // Fetch both games and existing threads in parallel
      const [fetchedGames, threadsData] = await Promise.all([
        fetchGames(dateObj),
        fetchGameThreads({ date: dateTime }),
      ]);

      setGames(fetchedGames);

      // Filter threads for this subreddit
      const subredditThreads = threadsData.data.filter(
        (thread) => thread.subreddit.id.toString() === selectedSubredditId,
      );
      setExistingThreads(subredditThreads);
    } catch (err) {
      setError('Failed to load games. Please try again.');
      console.error('Error fetching games:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubredditChange = async (subredditId: string) => {
    setSelectedSubredditId(subredditId);
    setSelectedGame(null);
    setGames([]);

    // Set defaults from subreddit
    const subreddit = subreddits.find((s) => s.id.toString() === subredditId);
    if (subreddit) {
      // Set default title
      const defaultTitle = subreddit.options.gameThreads?.title || '';
      setTitle(defaultTitle);

      // Set default hours from postAt - will be calculated when game is selected
      // For now, set a placeholder
      setPostAt(undefined);
    } else {
      setTitle('');
      setPostAt(undefined);
    }

    // Reload games if date is already selected
    if (selectedDate && subredditId) {
      await loadGamesForDate(selectedDate);
    }
  };

  const handleDateChange = async (date: string) => {
    setSelectedDate(date);
    if (date && selectedSubredditId) {
      await loadGamesForDate(date);
    } else {
      setSelectedGame(null);
      setGames([]);
      setExistingThreads([]);
    }
  };

  const calculateHoursFromPostAt = (postAt: string, gameStartTime: DateTime): number => {
    // If postAt is like "-3", it's 3 hours before game start
    if (postAt.startsWith('-')) {
      return Math.abs(Number.parseInt(postAt, 10));
    }

    // If it's a time like "3:00", calculate hours from that time on game day to game start
    // Note: postAt times are in Pacific timezone according to the UI
    const timeMatch = postAt.match(/^(\d{1,2}):(\d{2})$/);
    if (timeMatch) {
      const [, hourStr, minuteStr] = timeMatch;
      const hour = Number.parseInt(hourStr, 10);
      const minute = Number.parseInt(minuteStr, 10);

      // Convert game start time to Pacific timezone for calculation
      const gameStartPacific = gameStartTime.setZone('America/Los_Angeles');

      // Create a DateTime for the post time on the game day (in Pacific time)
      const postTime = gameStartPacific.startOf('day').set({ hour, minute });

      // Calculate difference in hours
      const diff = gameStartPacific.diff(postTime, 'hours');
      const hoursBefore = Math.round(diff.hours);

      // If post time is after game start, return 0 (shouldn't happen, but handle it)
      return Math.max(0, hoursBefore);
    }

    // Default to 1 hour if we can't parse it
    return 1;
  };

  const handleGameSelect = (game: ScheduleGame) => {
    setSelectedGame(game);

    // Calculate and set default hours based on postAt and game start time
    if (selectedSubreddit) {
      const postAt = selectedSubreddit.options.gameThreads?.postAt;
      if (postAt && game.gameDate) {
        const gameStartTime = DateTime.fromISO(game.gameDate);

        setPostAt(adjustPostAt(gameStartTime, postAt));
      }
    }
  };

  const handleCreate = async () => {
    if (!selectedSubredditId || !selectedDate || !selectedGame) {
      setError('Please fill in all required fields.');
      return;
    }

    if (!title.trim()) {
      setError('Please enter a title.');
      return;
    }

    if (!DateTime.isDateTime(postAt)) {
      setError('Please enter a valid posting time.');
      return;
    }

    setCreating(true);
    setError(null);

    try {
      await createGameThread({
        subredditId: Number.parseInt(selectedSubredditId, 10),
        gamePk: selectedGame.gamePk,
        title: title.trim(),
        postAt,
      });

      navigate({
        to: '/game_threads',
        search: { date: selectedDate },
      });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create game thread. Please try again.');
      console.error('Error creating game thread:', err);
    } finally {
      setCreating(false);
    }
  };

  if (!isLoggedIn) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <Text>You must be logged in to create game threads.</Text>
      </div>
    );
  }

  if (moderatedSubreddits.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <Text>You must be a moderator of at least one subreddit to create game threads.</Text>
      </div>
    );
  }

  return (
    <>
      <div className="flex w-full flex-wrap items-end justify-between gap-4 border-zinc-950/10 border-b pb-6 dark:border-white/10">
        <Heading>New Game Thread</Heading>
      </div>

      <div className="mt-6 space-y-6">
        <SubredditSelector
          selectedSubredditId={selectedSubredditId}
          handleSubredditChange={handleSubredditChange}
          moderatedSubreddits={moderatedSubreddits}
        />

        {selectedSubredditId && (
          <>
            <DateSelector selectedDate={selectedDate} handleDateChange={handleDateChange} />

            {loading && <Text>Loading games...</Text>}
            {error && <Text className="text-red-600 dark:text-red-400">{error}</Text>}

            {!loading && games.length > 0 && (
              <>
                <GameSelector
                  selectedDate={selectedDate}
                  games={games}
                  existingThreads={existingThreads}
                  selectedGame={selectedGame}
                  handleGameSelect={handleGameSelect}
                />

                {selectedGame && (
                  <>
                    <Fieldset>
                      <Field>
                        <Label>Title</Label>
                        <Input
                          type="text"
                          value={title}
                          onChange={(e) => setTitle(e.target.value)}
                          placeholder={selectedSubreddit?.options.gameThreads?.title || 'Game Thread Title'}
                        />
                      </Field>
                    </Fieldset>

                    <Fieldset>
                      <Field>
                        <Label>Post At</Label>
                        <Input
                          type="datetime-local"
                          value={postAt?.toISO() ?? ''}
                          onChange={(e) => setPostAt(DateTime.fromISO(e.target.value))}
                          placeholder="Select a time"
                        />
                      </Field>
                    </Fieldset>

                    <div className="flex gap-4">
                      <Button style="solid" onClick={handleCreate} disabled={creating}>
                        {creating ? 'Creating...' : 'Create Game Thread'}
                      </Button>
                      <Button
                        style="outline"
                        onClick={() => {
                          setSelectedGame(null);
                          setTitle('');
                          setPostAt(undefined);
                        }}
                      >
                        Cancel
                      </Button>
                    </div>
                  </>
                )}
              </>
            )}

            {!loading && games.length === 0 && selectedDate && <Text>No games found for this date.</Text>}
          </>
        )}
      </div>
    </>
  );
}

function SubredditSelector({
  selectedSubredditId,
  handleSubredditChange,
  moderatedSubreddits,
}: {
  selectedSubredditId: string;
  handleSubredditChange: (subredditId: string) => void;
  moderatedSubreddits: Subreddit[];
}) {
  return (
    <Fieldset>
      <Field>
        <Label>Subreddit</Label>
        <Select value={selectedSubredditId} onChange={(e) => handleSubredditChange(e.target.value)}>
          <option value="">Select a subreddit</option>
          {moderatedSubreddits.map((subreddit) => (
            <option key={subreddit.id} value={subreddit.id.toString()}>
              r/{subreddit.name}
            </option>
          ))}
        </Select>
      </Field>
    </Fieldset>
  );
}

function DateSelector({
  selectedDate,
  handleDateChange,
}: {
  selectedDate: string;
  handleDateChange: (newDate: string) => void;
}) {
  return (
    <Fieldset>
      <Field>
        <Label>Date</Label>
        <Input type="date" value={selectedDate} onChange={(e) => handleDateChange(e.target.value)} />
      </Field>
    </Fieldset>
  );
}

function GameSelector({
  selectedDate,
  games,
  existingThreads,
  selectedGame,
  handleGameSelect,
}: {
  selectedDate: string;
  games: ScheduleGame[];
  existingThreads: GameThread[];
  selectedGame: ScheduleGame | null;
  handleGameSelect: (game: ScheduleGame) => void;
}) {
  return (
    <div>
      <Heading level={2} className="mb-4">
        Games on {DateTime.fromISO(selectedDate).toLocaleString(DateTime.DATE_FULL)}
      </Heading>
      <Table>
        <TableHead>
          <TableRow>
            <TableHeader>Time</TableHeader>
            <TableHeader>Away Team</TableHeader>
            <TableHeader>Home Team</TableHeader>
            <TableHeader>Status</TableHeader>
            <TableHeader />
          </TableRow>
        </TableHead>
        <TableBody>
          {games.map((game) => {
            const hasExistingThread = existingThreads.some((thread) => thread.gamePk === game.gamePk);
            const isSelected = selectedGame?.gamePk === game.gamePk;

            return (
              <TableRow
                key={game.gamePk}
                className={
                  isSelected
                    ? 'bg-blue-50 dark:bg-blue-950/20'
                    : hasExistingThread
                      ? 'bg-zinc-50 opacity-50 dark:bg-zinc-900/20'
                      : ''
                }
              >
                <TableCell>
                  {game.gameDate ? DateTime.fromISO(game.gameDate).toLocaleString(DateTime.TIME_SIMPLE) : 'TBD'}
                </TableCell>
                <TableCell>{game.teams.away.team.teamName}</TableCell>
                <TableCell>{game.teams.home.team.teamName}</TableCell>
                <TableCell>{game.status.abstractGameState}</TableCell>
                <TableCell>
                  {hasExistingThread ? (
                    <div className="flex flex-col gap-1">
                      <Text className="text-sm text-zinc-500 dark:text-zinc-400">Already scheduled</Text>
                      <Link
                        to={'/game_threads/$threadId/edit' as any}
                        params={{
                          threadId: existingThreads.find((t) => t.gamePk === game.gamePk)?.id.toString() || '',
                        }}
                        className="text-sm"
                      >
                        Edit thread
                      </Link>
                    </div>
                  ) : (
                    <Button
                      style={isSelected ? 'solid' : 'outline'}
                      onClick={() => handleGameSelect(game)}
                      disabled={hasExistingThread}
                    >
                      {isSelected ? 'Selected' : 'Select'}
                    </Button>
                  )}
                </TableCell>
              </TableRow>
            );
          })}
        </TableBody>
      </Table>
    </div>
  );
}
