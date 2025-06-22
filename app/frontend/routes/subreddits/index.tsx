import { createFileRoute } from '@tanstack/react-router';

async function fetchSubreddits() {
  return fetch('//baseballbot.io.test/subreddits.json').then((res) => res.json());
}

export const Route = createFileRoute('/subreddits/')({
  component: RouteComponent,
  loader: fetchSubreddits,
});

function RouteComponent() {
  const { data: subreddits } = Route.useLoaderData();

  console.log(subreddits);

  return (
    <div className="p-2">
      <h3>Hello from Subreddits!</h3>
    </div>
  );
}
