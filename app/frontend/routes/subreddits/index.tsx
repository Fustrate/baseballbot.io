import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/subreddits/')({
  component: RouteComponent,
  loader: async () => {
    return fetch('//baseballbot.io.test/subreddits.json').then((res) => res.json());
  },
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
