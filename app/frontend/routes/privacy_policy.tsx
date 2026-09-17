import { createFileRoute } from '@tanstack/react-router';
import { Heading } from '@/catalyst/heading';
import { Text } from '@/catalyst/text';

export const Route = createFileRoute('/privacy_policy')({
  component: RouteComponent,
  head: () => ({
    meta: [{ title: 'Privacy Policy' }],
  }),
});

function RouteComponent() {
  return (
    <div className="space-y-6">
      <Heading>Privacy Policy</Heading>

      <Text>
        Baseballbot.io does not collect any personal information and does not track users. Your Reddit ID is used to
        sync preferences regarding UI behavior, and is deleted 30 days after your last interaction with BaseballBot.
      </Text>
    </div>
  );
}
