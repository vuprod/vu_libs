import { ToastPosition } from 'react-hot-toast';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { CSSProperties } from 'react';
import { IconAnimation } from '../components/LibIcon';

export type NotificationType = 'info' | 'warning' | 'success' | 'error' | string;

export interface NotificationProps {
  id?: number | string;
  title?: string;
  description?: string;
  duration?: number;
  showDuration?: boolean;
  position?: ToastPosition | 'top' | 'bottom';
  type?: NotificationType;

  /** FontAwesome icon name, or [prefix, name] */
  icon?: IconProp | string | [string, string] | false;
  iconColor?: string;
  iconAnimation?: IconAnimation;
  iconSize?: number;
  alignIcon?: 'top' | 'center';
  hideIcon?: boolean;

  /** Duration ring around icon (defaults to iconColor) */
  durationColor?: string;

  /** Surface */
  backgroundColor?: string;
  color?: string;
  descriptionColor?: string;
  borderColor?: string;
  borderWidth?: number | string;
  borderRadius?: number | string;
  width?: number | string;
  padding?: number | string;
  opacity?: number;
  shadow?: string | boolean;
  fontFamily?: string;
  titleFontSize?: number | string;
  descriptionFontSize?: number | string;
  titleFontWeight?: number | string;

  /** Raw CSS merge — highest priority overrides */
  style?: CSSProperties;
}
