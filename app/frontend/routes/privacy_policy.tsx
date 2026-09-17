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

      <Text>This page describes how Baseballbot.io collects, uses, and protects your information.</Text>
    </div>
  );
}
