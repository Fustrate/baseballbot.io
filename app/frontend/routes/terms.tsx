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

      <Text>
        Baseballbot.io is provided as-is, with no warranties. By using this site and the associated BaseballBot reddit
        application, you agree to use it responsibly and in accordance with Reddit's own terms of service.
      </Text>
    </div>
  );
}
