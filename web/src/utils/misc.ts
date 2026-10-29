export const isEnvBrowser = (): boolean => !(window as Window).invokeNative;

export const noop = () => {};
