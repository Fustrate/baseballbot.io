import { createFileRoute } from '@tanstack/react-router';
import { Text } from '@/catalyst/text';

export const Route = createFileRoute('/game_threads/$threadId')({
  component: RouteComponent,
  loader: async ({ params }) => {
    const { threadId } = params;

    return { threadId };
  },
});

function RouteComponent() {
  return <Text>Hello "/game_threads/$threadId"!</Text>;
}
