/**
 * File generated by js-routes RubyVariables.GEM_VERSION
 * Based on Rails RubyVariables.RAILS_VERSION routes of RubyVariables.APP_CLASS
 */
declare type Optional<T> = {
    [P in keyof T]?: T[P] | null;
};
declare type BaseRouteParameter = string | boolean | Date | number;
declare type MethodRouteParameter = BaseRouteParameter | (() => BaseRouteParameter);
declare type ModelRouteParameter = {
    id: MethodRouteParameter;
} | {
    to_param: MethodRouteParameter;
} | {
    toParam: MethodRouteParameter;
};
declare type RequiredRouteParameter = BaseRouteParameter | ModelRouteParameter;
declare type OptionalRouteParameter = undefined | null | RequiredRouteParameter;
declare type QueryRouteParameter = OptionalRouteParameter | QueryRouteParameter[] | {
    [k: string]: QueryRouteParameter;
};
declare type RouteParameters = Record<string, QueryRouteParameter>;
declare type Serializable = Record<string, unknown>;
declare type Serializer = (value: Serializable) => string;
declare type RouteHelperExtras = {
    requiredParams(): string[];
    toString(): string;
};
declare type RequiredParameters<T extends number> = T extends 1 ? [RequiredRouteParameter] : T extends 2 ? [RequiredRouteParameter, RequiredRouteParameter] : T extends 3 ? [RequiredRouteParameter, RequiredRouteParameter, RequiredRouteParameter] : T extends 4 ? [
    RequiredRouteParameter,
    RequiredRouteParameter,
    RequiredRouteParameter,
    RequiredRouteParameter
] : RequiredRouteParameter[];
declare type RouteHelperOptions = RouteOptions & Record<string, OptionalRouteParameter>;
declare type RouteHelper<T extends number = number> = ((...args: [...RequiredParameters<T>, RouteHelperOptions]) => string) & RouteHelperExtras;
declare type RouteHelpers = Record<string, RouteHelper>;
declare type Configuration = {
    prefix: string;
    default_url_options: RouteParameters;
    special_options_key: string;
    serializer: Serializer;
};
interface RouterExposedMethods {
    config(): Configuration;
    configure(arg: Partial<Configuration>): Configuration;
    serialize: Serializer;
}
declare type KeywordUrlOptions = Optional<{
    host: string;
    protocol: string;
    subdomain: string;
    port: string | number;
    anchor: string;
    trailing_slash: boolean;
    params: RouteParameters;
}>;
declare type RouteOptions = KeywordUrlOptions & RouteParameters;
declare type PartsTable = Record<string, {
    r?: boolean;
    d?: OptionalRouteParameter;
}>;
declare type ModuleType = "CJS" | "AMD" | "UMD" | "ESM" | "DTS" | "NIL";
declare const RubyVariables: {
    PREFIX: string;
    DEPRECATED_GLOBBING_BEHAVIOR: boolean;
    DEPRECATED_FALSE_PARAMETER_BEHAVIOR: boolean;
    SPECIAL_OPTIONS_KEY: string;
    DEFAULT_URL_OPTIONS: RouteParameters;
    SERIALIZER: Serializer;
    ROUTES_OBJECT: RouteHelpers;
    MODULE_TYPE: ModuleType;
    WRAPPER: <T>(callback: T) => T;
};
declare const define: undefined | (((arg: unknown[], callback: () => unknown) => void) & {
    amd?: unknown;
});
declare const module: {
    exports: any;
} | undefined;
export const configure: RouterExposedMethods['configure'];

export const config: RouterExposedMethods['config'];

export const serialize: RouterExposedMethods['serialize'];

export const accountsAuthenticatePath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const editGameThreadPath: ((
  id: RequiredRouteParameter,
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const editSubredditPath: ((
  id: RequiredRouteParameter,
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const gameThreadPath: ((
  id: RequiredRouteParameter,
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const gameThreadsPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const gameThreadsSubredditPath: ((
  id: RequiredRouteParameter,
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const gamechatsPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const gamedayPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const loginPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const logoutPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const newGameThreadPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const railsInfoPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const railsInfoPropertiesPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const railsInfoRoutesPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const railsMailersPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const rootPath: ((
  options?: {} & RouteOptions
) => string) & RouteHelperExtras;

export const sidekiqWebPath: ((
  options?: {} & RouteOptions
) => string) & RouteHelperExtras;

export const signUpAuthorizedPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const signUpFinishPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const signUpStartPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const slackCommandsGDTPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const slackInteractivityPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const subredditPath: ((
  id: RequiredRouteParameter,
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const subredditsPath: ((
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

export const templatePath: ((
  id: RequiredRouteParameter,
  options?: {format?: OptionalRouteParameter} & RouteOptions
) => string) & RouteHelperExtras;

// By some reason this line prevents all types in a file
// from being automatically exported
export {};
