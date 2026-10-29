import { isEnvBrowser } from './misc';

const nativeFetch = window.fetch.bind(window);

export async function fetchNui<T = unknown>(eventName: string, data?: unknown): Promise<T> {
  if (isEnvBrowser()) {
    console.debug(`[vu_libs:dev] fetchNui('${eventName}')`, data);
    return {} as T;
  }

  const options: RequestInit = {
    method: 'post',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data ?? {}),
  };

  const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'vu_libs';

  const resp = await nativeFetch(`https://${resourceName}/${eventName}`, options);
  return (await resp.json()) as T;
}
