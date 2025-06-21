/* biome-ignore lint/correctness/noUnusedImports: auto-generated */
import { type OptionalParameter, type RequiredParameter, type RouteOptions, buildRoute } from './routes.utils';

export const accountsAuthenticatePath = (options: RouteOptions = {}) =>
  buildRoute('/accounts/authenticate(.:format)', { ...options });
export const appPath = (options: RouteOptions = {}) => buildRoute('/', { ...options });
export const editGameThreadPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/game_threads/:id/edit(.:format)', { id, ...options });
export const editSubredditPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/subreddits/:id/edit(.:format)', { id, ...options });
export const gameThreadPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/game_threads/:id(.:format)', { id, ...options });
export const gameThreadsPath = (options: RouteOptions = {}) => buildRoute('/game_threads(.:format)', { ...options });
export const gameThreadsSubredditPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/subreddits/:id/game_threads(.:format)', { id, ...options });
export const gamechatsPath = (options: RouteOptions = {}) => buildRoute('/gamechats(.:format)', { ...options });
export const gamedayPath = (options: RouteOptions = {}) => buildRoute('/gameday(.:format)', { ...options });
export const loginPath = (options: RouteOptions = {}) => buildRoute('/login(.:format)', { ...options });
export const logoutPath = (options: RouteOptions = {}) => buildRoute('/logout(.:format)', { ...options });
export const newGameThreadPath = (options: RouteOptions = {}) =>
  buildRoute('/game_threads/new(.:format)', { ...options });
export const rootPath = (options: RouteOptions = {}) => buildRoute('/', { ...options });
export const signUpAuthorizedPath = (options: RouteOptions = {}) =>
  buildRoute('/sign_up/authorized(.:format)', { ...options });
export const signUpFinishPath = (options: RouteOptions = {}) => buildRoute('/sign_up/finish(.:format)', { ...options });
export const signUpStartPath = (options: RouteOptions = {}) => buildRoute('/sign_up/start(.:format)', { ...options });
export const subredditPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/subreddits/:id(.:format)', { id, ...options });
export const subredditsPath = (options: RouteOptions = {}) => buildRoute('/subreddits(.:format)', { ...options });
export const templatePath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/templates/:id(.:format)', { id, ...options });
