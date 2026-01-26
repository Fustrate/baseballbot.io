import { createFileRoute, redirect, useNavigate } from '@tanstack/react-router';
import { type SetStateAction, useState } from 'react';
import { fetchSession } from '@/api/session';
import { fetchSubreddit, isModerator, type SubredditOptions, updateSubreddit } from '@/api/subreddits';
import { Button } from '@/catalyst/button';
import { Checkbox, CheckboxField } from '@/catalyst/checkbox';
import { Description, Field, FieldGroup, Fieldset, Label, Legend } from '@/catalyst/fieldset';
import { Heading } from '@/catalyst/heading';
import { Input } from '@/catalyst/input';
import { Select } from '@/catalyst/select';
import { Text } from '@/catalyst/text';
import { Textarea } from '@/catalyst/textarea';

export const Route = createFileRoute('/subreddits_/$subredditId/edit')({
  component: RouteComponent,
  loader: async ({ params }) => {
    const { subredditId } = params;

    const [{ user }, subreddit] = await Promise.all([fetchSession(), fetchSubreddit(subredditId)]);

    if (!isModerator(user, subreddit)) {
      throw redirect({
        to: '/subreddits/$subredditId',
        params: { subredditId },
      });
    }

    return { subreddit };
  },
  head: ({ params }) => ({
    meta: [{ title: `Edit /r/${params.subredditId}` }],
  }),
});

function RouteComponent() {
  const { subreddit } = Route.useLoaderData();
  const navigate = useNavigate();

  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [options, setOptions] = useState(subreddit.options);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    setIsSaving(true);
    setError(null);

    try {
      await updateSubreddit(subreddit.name, options);
      navigate({ to: '/subreddits/$subredditId', params: { subredditId: subreddit.name } });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update subreddit');
      setIsSaving(false);
    }
  };

  return (
    <div className="flex flex-col gap-6">
      <div className="flex w-full flex-wrap items-end justify-between gap-4 border-zinc-950/10 border-b pb-6 dark:border-white/10">
        <Heading>Edit /r/{subreddit.name}</Heading>
      </div>

      {error && (
        <div className="rounded-lg bg-red-50 p-4 dark:bg-red-900/20">
          <Text className="text-red-800 dark:text-red-200">{error}</Text>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-10">
        <GeneralSettings options={options} setOptions={setOptions} />

        <SidebarSettings options={options.sidebar} setOptions={setOptions} />

        <GameThreadSettings options={options.gameThreads} setOptions={setOptions} />

        <PreGameSettings options={options.pregame} setOptions={setOptions} />

        <PostGameSettings options={options.postgame} setOptions={setOptions} />

        <OffDaySettings options={options.offDay} setOptions={setOptions} />

        <div className="flex gap-4">
          <Button type="submit" disabled={isSaving}>
            {isSaving ? 'Saving...' : 'Save Changes'}
          </Button>
          <Button
            type="button"
            style="outline"
            onClick={() => navigate({ to: '/subreddits/$subredditId', params: { subredditId: subreddit.name } })}
          >
            Cancel
          </Button>
        </div>
      </form>
    </div>
  );
}

function GeneralSettings({
  options,
  setOptions,
}: {
  options: SubredditOptions;
  setOptions: (value: SetStateAction<SubredditOptions>) => void;
}) {
  return (
    <Fieldset>
      <Legend>General Settings</Legend>
      <FieldGroup>
        <Field>
          <Label>Sticky Slot</Label>
          <Select
            name="stickySlot"
            value={options.stickySlot ?? ''}
            onChange={(e) =>
              setOptions({ ...options, stickySlot: e.target.value ? (Number(e.target.value) as 1 | 2) : undefined })
            }
          >
            <option value="">Default</option>
            <option value="1">Prefer Slot 1</option>
            <option value="2">Prefer Slot 2</option>
          </Select>
          <Description>Which sticky position to use (1 or 2)</Description>
        </Field>
      </FieldGroup>
    </Fieldset>
  );
}

function SidebarSettings({
  options,
  setOptions,
}: {
  options: SubredditOptions['sidebar'];
  setOptions: (value: SetStateAction<SubredditOptions>) => void;
}) {
  function setSidebarOption(setting: Partial<SubredditOptions['sidebar']>) {
    setOptions((existing) => ({
      ...existing,
      sidebar: { enabled: true, ...options, ...setting },
    }));
  }

  return (
    <Fieldset>
      <Legend>Sidebar Updates</Legend>
      <FieldGroup>
        <CheckboxField>
          <Checkbox
            name="subreddit[options][sidebar][enabled]"
            checked={options?.enabled ?? false}
            onChange={(checked) => setSidebarOption({ enabled: checked })}
          />
          <Label>Enable Sidebar Updates</Label>
        </CheckboxField>
      </FieldGroup>
    </Fieldset>
  );
}

function GameThreadSettings({
  options,
  setOptions,
}: {
  options: SubredditOptions['gameThreads'];
  setOptions: (value: SetStateAction<SubredditOptions>) => void;
}) {
  function setGameThreadOption(setting: Partial<SubredditOptions['gameThreads']>) {
    setOptions((existing) => ({
      ...existing,
      gameThreads: { enabled: true, ...options, ...setting },
    }));
  }

  return (
    <Fieldset>
      <Legend>Game Threads</Legend>
      <FieldGroup>
        <CheckboxField>
          <Checkbox
            name="subreddit[options][gameThreads][enabled]"
            checked={options?.enabled ?? false}
            onChange={(checked) => setGameThreadOption({ enabled: checked })}
          />
          <Label>Enable Game Threads</Label>
        </CheckboxField>

        {options?.enabled && (
          <>
            <Field>
              <Label>Post At</Label>
              <Select
                name="subreddit[options][gameThreads][postAt]"
                value={options.postAt ?? '-3'}
                onChange={(e) => setGameThreadOption({ postAt: e.target.value })}
              >
                <PostAtOptions offset clock />
              </Select>
              <Description>Note that times are always interpreted in the Pacific time zone.</Description>
            </Field>

            <CheckboxField>
              <Checkbox
                name="subreddit[options][gameThreads][sticky]"
                checked={options.sticky !== false}
                onChange={(checked) => setGameThreadOption({ sticky: checked })}
              />
              <Label>Sticky Game Threads</Label>
            </CheckboxField>

            <Field>
              <Label>Flair ID</Label>
              <Input
                name="subreddit[options][gameThreads][flairId]"
                value={options.flairId ?? ''}
                onChange={(e) => setGameThreadOption({ flairId: e.target.value })}
              />
              <Description>Optional flair template ID for the post</Description>
            </Field>

            <Field>
              <Label>Default Title</Label>
              <Input
                name="subreddit[options][gameThreads][title]"
                value={options.title ?? ''}
                onChange={(e) => setGameThreadOption({ title: e.target.value })}
              />
              <Description>Optional flair template ID for the post</Description>
            </Field>

            <Field>
              <Label>Postseason Title</Label>
              <Input
                name="subreddit[options][gameThreads][title.postseason]"
                value={options['title.postseason'] ?? ''}
                onChange={(e) => setGameThreadOption({ 'title.postseason': e.target.value })}
              />
              <Description>Optional separate title for postseason games</Description>
            </Field>

            <Field>
              <Label>Sticky Comment</Label>
              <Textarea
                name="subreddit[options][gameThreads][stickyComment]"
                value={options.stickyComment ?? ''}
                rows={3}
                onChange={(e) => setGameThreadOption({ stickyComment: e.target.value })}
              />
              <Description>Optional comment to sticky at the top of the thread</Description>
            </Field>
          </>
        )}
      </FieldGroup>
    </Fieldset>
  );
}

function PreGameSettings({
  options,
  setOptions,
}: {
  options: SubredditOptions['pregame'];
  setOptions: (value: SetStateAction<SubredditOptions>) => void;
}) {
  function setPreGameOption(setting: Partial<SubredditOptions['pregame']>) {
    setOptions((existing) => ({
      ...existing,
      pregame: { enabled: true, ...options, ...setting },
    }));
  }

  return (
    <Fieldset>
      <Legend>Pregame Threads</Legend>
      <FieldGroup>
        <CheckboxField>
          <Checkbox
            name="subreddit[options][pregame][enabled]"
            checked={options?.enabled ?? false}
            onChange={(checked) => setPreGameOption({ enabled: checked })}
          />
          <Label>Enable Pregame Threads</Label>
        </CheckboxField>

        {options?.enabled && (
          <>
            <Field>
              <Label>Post At</Label>
              <Select
                name="subreddit[options][pregame][postAt]"
                value={options.postAt ?? '-3'}
                onChange={(e) => setPreGameOption({ postAt: e.target.value })}
              >
                <PostAtOptions offset clock />
              </Select>
              <Description>Note that times are always interpreted in the Pacific time zone.</Description>
            </Field>

            <CheckboxField>
              <Checkbox
                name="subreddit[options][pregame][sticky]"
                checked={options.sticky !== false}
                onChange={(checked) => setPreGameOption({ sticky: checked })}
              />
              <Label>Sticky Pregame Threads</Label>
            </CheckboxField>

            <Field>
              <Label>Sticky Comment</Label>
              <Textarea
                name="subreddit[options][pregame][stickyComment]"
                value={options.stickyComment ?? ''}
                rows={3}
                onChange={(e) => setPreGameOption({ stickyComment: e.target.value })}
              />
              <Description>Optional comment to sticky at the top of the thread</Description>
            </Field>
          </>
        )}
      </FieldGroup>
    </Fieldset>
  );
}

function PostGameSettings({
  options,
  setOptions,
}: {
  options: SubredditOptions['postgame'];
  setOptions: (value: SetStateAction<SubredditOptions>) => void;
}) {
  function setPostgameOption(setting: Partial<SubredditOptions['postgame']>) {
    setOptions((existing) => ({
      ...existing,
      postgame: { enabled: true, ...options, ...setting },
    }));
  }

  return (
    <Fieldset>
      <Legend>Postgame Threads</Legend>
      <FieldGroup>
        <CheckboxField>
          <Checkbox
            name="subreddit[options][postgame][enabled]"
            checked={options?.enabled ?? false}
            onChange={(checked) => setPostgameOption({ enabled: checked })}
          />
          <Label>Enable Postgame Threads</Label>
        </CheckboxField>

        {options?.enabled && (
          <>
            <CheckboxField>
              <Checkbox
                name="subreddit[options][postgame][sticky]"
                checked={options.sticky !== false}
                onChange={(checked) => setPostgameOption({ sticky: checked })}
              />
              <Label>Sticky Postgame Threads</Label>
            </CheckboxField>

            <Field>
              <Label>Postgame Title</Label>
              <Input
                name="subreddit[options][postgame][title]"
                value={options.title ?? ''}
                onChange={(e) => setPostgameOption({ title: e.target.value })}
              />
            </Field>

            <Field>
              <Label>Postgame Title - Win</Label>
              <Input
                name="subreddit[options][postgame][title.won]"
                value={options['title.won'] ?? ''}
                onChange={(e) => setPostgameOption({ 'title.won': e.target.value })}
                required
              />
              <Description>Optional separate title when your team wins</Description>
            </Field>

            <Field>
              <Label>Postgame Title - Loss</Label>
              <Input
                name="subreddit[options][postgame][title.lost]"
                value={options['title.lost'] ?? ''}
                onChange={(e) => setPostgameOption({ 'title.lost': e.target.value })}
              />
              <Description>Optional separate title when your team loses</Description>
            </Field>

            <Field>
              <Label>Sticky Comment</Label>
              <Textarea
                name="subreddit[options][postgame][stickyComment]"
                value={options.stickyComment ?? ''}
                rows={3}
                onChange={(e) => setPostgameOption({ stickyComment: e.target.value })}
              />
              <Description>Optional comment to sticky at the top of the postgame thread</Description>
            </Field>
          </>
        )}
      </FieldGroup>
    </Fieldset>
  );
}

function OffDaySettings({
  options,
  setOptions,
}: {
  options: SubredditOptions['offDay'];
  setOptions: (options: any) => void;
}) {
  function setOffDayOption(setting: Partial<SubredditOptions['offDay']>) {
    setOptions((existing) => ({
      ...existing,
      offDay: { enabled: true, ...options, ...setting },
    }));
  }

  return (
    <Fieldset>
      <Legend>Off Day Threads</Legend>
      <FieldGroup>
        <CheckboxField>
          <Checkbox
            name="subreddit[options][offDay][enabled]"
            checked={options?.enabled ?? false}
            onChange={(checked) => setOffDayOption({ enabled: checked })}
          />
          <Label>Enable off day threads</Label>
        </CheckboxField>

        {options?.enabled && (
          <>
            <Field>
              <Label>Title</Label>
              <Input
                name="subreddit[options][offDay][title]"
                value={options?.title}
                onChange={(e) => setOffDayOption({ title: e.target.value })}
              />
            </Field>

            <Field>
              <Label>Post At</Label>
              <Select
                name="subreddit[options][offDay][postAt]"
                value={options?.postAt ?? '-3'}
                onChange={(e) => setOffDayOption({ postAt: e.target.value })}
              >
                <PostAtOptions clock />
              </Select>
              <Description>Note that times are always interpreted in the Pacific time zone.</Description>
            </Field>

            <CheckboxField>
              <Checkbox
                name="subreddit[options][offDay][sticky]"
                checked={options?.sticky !== false}
                onChange={(checked) => setOffDayOption({ sticky: checked })}
              />
              <Label>Sticky thread</Label>
            </CheckboxField>

            <Field>
              <Label>Sticky Comment</Label>
              <Textarea
                name="subreddit[options][offDay][stickyComment]"
                value={options?.stickyComment ?? ''}
                rows={3}
                onChange={(e) => setOffDayOption({ stickyComment: e.target.value })}
              />
              <Description>Optional comment to sticky at the top of the thread</Description>
            </Field>
          </>
        )}
      </FieldGroup>
    </Fieldset>
  );
}

function PostAtOptions({ offset, clock }: { offset?: boolean; clock?: boolean }) {
  return (
    <>
      {offset && (
        <>
          <option value="-1">1 Hour Pregame</option>
          <option value="-2">2 Hours Pregame</option>
          <option value="-3">3 Hours Pregame</option>
          <option value="-4">4 Hours Pregame</option>
          <option value="-5">5 Hours Pregame</option>
          <option value="-6">6 Hours Pregame</option>
          <option value="-7">7 Hours Pregame</option>
          <option value="-8">8 Hours Pregame</option>
          <option value="-9">9 Hours Pregame</option>
          <option value="-10">10 Hours Pregame</option>
          <option value="-11">11 Hours Pregame</option>
          <option value="-12">12 Hours Pregame</option>
        </>
      )}
      {clock && (
        <>
          <option value="1:00">1 AM Pacific</option>
          <option value="2:00">2 AM Pacific</option>
          <option value="3:00">3 AM Pacific</option>
          <option value="4:00">4 AM Pacific</option>
          <option value="5:00">5 AM Pacific</option>
          <option value="6:00">6 AM Pacific</option>
          <option value="7:00">7 AM Pacific</option>
          <option value="8:00">8 AM Pacific</option>
          <option value="9:00">9 AM Pacific</option>
          <option value="10:00">10 AM Pacific</option>
          <option value="11:00">11 AM Pacific</option>
          <option value="12:00">12 PM Pacific</option>
        </>
      )}
    </>
  );
}
