import { MantineThemeOverride, Tuple } from '@mantine/core';

/** Soft cyan palette — close to ox_lib blue, but clearly VU */
const vuCyan: Tuple<string, 10> = [
  '#e6f9ff',
  '#c2effa',
  '#99e0f5',
  '#6dcee8',
  '#4db8e8',
  '#35a3d9',
  '#2a8fbf',
  '#2278a1',
  '#1c6285',
  '#154d69',
];

export const theme: MantineThemeOverride = {
  colorScheme: 'dark',
  fontFamily: 'Roboto, sans-serif',
  primaryColor: 'cyan',
  primaryShade: 5,
  colors: {
    cyan: vuCyan,
  },
  radius: {
    sm: 6,
  },
  shadows: {
    sm: '0 4px 14px rgba(0, 0, 0, 0.45)',
  },
  other: {
    vuSurface: '#1e2229',
    vuSurfaceAlt: '#262b34',
    vuMuted: '#9aa3b2',
    vuText: '#e8ecf1',
  },
  components: {
    Button: {
      styles: {
        root: {
          border: 'none',
        },
      },
    },
  },
};

export const typeColors = {
  info: '#4db8e8',
  success: '#3dcc9a',
  warning: '#e8b84a',
  error: '#e86a6a',
} as const;
