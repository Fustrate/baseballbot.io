export interface User {
  id: number;
  username: string;
  subreddits: number[];
}

export interface SessionData {
  loggedIn: boolean;
  user?: User;
}

export async function fetchSession(): Promise<SessionData> {
  const response = await fetch('/api/session');
  return response.json();
}
