import { createContext, type ReactNode, useContext, useEffect, useState } from 'react';
import type { SessionData, User } from '@/api/session';
import { fetchSession } from '@/api/session';

interface AuthContextType {
  isLoggedIn: boolean;
  isLoading: boolean;
  user: User | null;
  refreshSession: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<SessionData>({ loggedIn: false });
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const loadSession = async () => {
      setIsLoading(true);

      try {
        const data = await fetchSession();
        setSession(data);
      } catch (error) {
        console.error('Failed to load session:', error);
        setSession({ loggedIn: false });
      } finally {
        setIsLoading(false);
      }
    };

    loadSession();
  }, []);

  const refreshSession = async () => {
    setIsLoading(true);

    try {
      const data = await fetchSession();
      setSession(data);
    } catch (error) {
      console.error('Failed to refresh session:', error);
      setSession({ loggedIn: false });
    } finally {
      setIsLoading(false);
    }
  };

  const value: AuthContextType = {
    isLoggedIn: session.loggedIn,
    isLoading,
    user: session.user ?? null,
    refreshSession,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);

  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }

  return context;
}
