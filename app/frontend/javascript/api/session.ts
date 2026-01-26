export interface User {
  id: number;
  username: string;
  subreddits: number[];
  type: 'user' | 'admin';
}

export interface SessionData {
  loggedIn: boolean;
  user?: User;
}

export async function fetchSession(): Promise<SessionData> {
  const response = await fetch('/api/session');
  return response.json();
}
