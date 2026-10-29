import { IconProp } from '@fortawesome/fontawesome-svg-core';
import React from 'react';
import { IconAnimation } from '../components/LibIcon';

export type TextUiPosition = 'right-center' | 'left-center' | 'top-center' | 'bottom-center';

export interface TextUiProps {
  text: string;
  position?: TextUiPosition;
  icon?: IconProp | string | [string, string];
  iconColor?: string;
  iconAnimation?: IconAnimation;
  style?: React.CSSProperties;
  alignIcon?: 'top' | 'center';
}
