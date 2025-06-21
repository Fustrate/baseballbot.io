import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/subreddits/')({
  component: RouteComponent,
})

function RouteComponent() {
  return <div className="p-2"><h3>Hello from Subreddits!</h3></div>
}
