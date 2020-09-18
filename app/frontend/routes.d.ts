declare module 'js/routes' {
  export type RouteComponent = string | number | { id?: number};

  export type RouteOptionsComponent = string | number | string[] | number[] | boolean;

  export type RouteOptions = {
    format?: string;
    [s: string]: RouteOptionsComponent;
  };

  export function accountsAuthenticatePath(options?: RouteOptions): string;
  export function discordDebugPath(options?: RouteOptions): string;
  export function discordRedditCallbackPath(options?: RouteOptions): string;
  export function editGameThreadPath(id: RouteComponent, options?: RouteOptions): string;
  export function gameThreadPath(id: RouteComponent, options?: RouteOptions): string;
  export function gameThreadsPath(options?: RouteOptions): string;
  export function gameThreadsSubredditPath(id: RouteComponent, options?: RouteOptions): string;
  export function gamechatsPath(options?: RouteOptions): string;
  export function gamedayPath(options?: RouteOptions): string;
  export function logInPath(options?: RouteOptions): string;
  export function newGameThreadPath(options?: RouteOptions): string;
  export function railsBlobRepresentationPath(signedBlobId: RouteComponent, variationKey: RouteComponent, filename: RouteComponent, options?: RouteOptions): string;
  export function railsDirectUploadsPath(options?: RouteOptions): string;
  export function railsDiskServicePath(encodedKey: RouteComponent, filename: RouteComponent, options?: RouteOptions): string;
  export function railsInfoPath(options?: RouteOptions): string;
  export function railsInfoPropertiesPath(options?: RouteOptions): string;
  export function railsInfoRoutesPath(options?: RouteOptions): string;
  export function railsMailersPath(options?: RouteOptions): string;
  export function railsServiceBlobPath(signedId: RouteComponent, filename: RouteComponent, options?: RouteOptions): string;
  export function rootPath(options?: { [s: string]: RouteOptionsComponent }): string;
  export function sidekiqWebPath(options?: { [s: string]: RouteOptionsComponent }): string;
  export function signOutPath(options?: RouteOptions): string;
  export function slackCommandsGDTPath(options?: RouteOptions): string;
  export function slackInteractivityPath(options?: RouteOptions): string;
  export function subredditPath(id: RouteComponent, options?: RouteOptions): string;
  export function subredditsPath(options?: RouteOptions): string;
  export function templatePath(id: RouteComponent, options?: RouteOptions): string;
  export function updateRailsDiskServicePath(encodedToken: RouteComponent, options?: RouteOptions): string;
}
