import { createFileRoute } from '@tanstack/react-router';
import { Heading } from '@/catalyst/heading';
import { Text } from '@/catalyst/text';

export const Route = createFileRoute('/terms')({
  component: RouteComponent,
  head: () => ({
    meta: [{ title: 'Terms of Service' }],
  }),
});

function RouteComponent() {
  return (
    <div className="space-y-6">
      <Heading>Terms of Service</Heading>

      <Text>These are the terms of service for using Baseballbot.io.</Text>
    </div>
  );
}
