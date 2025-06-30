/* biome-ignore lint/correctness/noUnusedImports: auto-generated */
import { type OptionalParameter, type RequiredParameter, type RouteOptions, buildRoute } from './routes.utils';

export const apiAccountsAuthenticatePath = (options: RouteOptions = {}) =>
  buildRoute('/api/accounts/authenticate(.:format)', { ...options });
export const apiGameThreadPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/api/game_threads/:id(.:format)', { id, ...options });
export const apiGameThreadsPath = (options: RouteOptions = {}) =>
  buildRoute('/api/game_threads(.:format)', { ...options });
export const apiLoginPath = (options: RouteOptions = {}) => buildRoute('/api/login(.:format)', { ...options });
export const apiLogoutPath = (options: RouteOptions = {}) => buildRoute('/api/logout(.:format)', { ...options });
export const apiSubredditPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/api/subreddits/:id(.:format)', { id, ...options });
export const apiSubredditsPath = (options: RouteOptions = {}) =>
  buildRoute('/api/subreddits(.:format)', { ...options });
export const apiTemplatePath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/api/templates/:id(.:format)', { id, ...options });
export const appPath = (options: RouteOptions = {}) => buildRoute('/', { ...options });
export const gameThreadsApiSubredditPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/api/subreddits/:id/game_threads(.:format)', { id, ...options });
export const templatesApiSubredditPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/api/subreddits/:id/templates(.:format)', { id, ...options });
