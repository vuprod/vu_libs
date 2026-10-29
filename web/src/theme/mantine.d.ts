import '@mantine/core';

declare module '@mantine/core' {
  export interface MantineThemeOther {
    vuSurface: string;
    vuSurfaceAlt: string;
    vuMuted: string;
    vuText: string;
  }
}
