import { buildRoute, type RequiredParameter, type RouteOptions } from './routes.utils';

export const apiGameThreadPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/api/game_threads/:id(.:format)', { id, ...options });
export const apiGameThreadsPath = (options: RouteOptions = {}) =>
  buildRoute('/api/game_threads(.:format)', { ...options });
export const apiSessionPath = (options: RouteOptions = {}) => buildRoute('/api/session(.:format)', { ...options });
export const apiSubredditPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/api/subreddits/:id(.:format)', { id, ...options });
export const apiSubredditsPath = (options: RouteOptions = {}) =>
  buildRoute('/api/subreddits(.:format)', { ...options });
export const apiTemplatePath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/api/templates/:id(.:format)', { id, ...options });
export const appPath = (options: RouteOptions = {}) => buildRoute('/', { ...options });
export const authorizedBotsPath = (options: RouteOptions = {}) =>
  buildRoute('/bots/authorized(.:format)', { ...options });
export const authorizedSessionPath = (options: RouteOptions = {}) =>
  buildRoute('/session/authorized(.:format)', { ...options });
export const gameThreadsApiSubredditPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/api/subreddits/:id/game_threads(.:format)', { id, ...options });
export const newBotPath = (options: RouteOptions = {}) => buildRoute('/bots/new(.:format)', { ...options });
export const newSessionPath = (options: RouteOptions = {}) => buildRoute('/session/new(.:format)', { ...options });
export const sessionPath = (options: RouteOptions = {}) => buildRoute('/session(.:format)', { ...options });
export const templatesApiSubredditPath = (id: RequiredParameter, options: RouteOptions = {}) =>
  buildRoute('/api/subreddits/:id/templates(.:format)', { id, ...options });
