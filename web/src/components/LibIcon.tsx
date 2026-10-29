import { FontAwesomeIcon, FontAwesomeIconProps } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';

export type IconAnimation =
  | 'spin'
  | 'spinPulse'
  | 'spinReverse'
  | 'pulse'
  | 'beat'
  | 'fade'
  | 'beatFade'
  | 'bounce'
  | 'shake';

interface LibIconProps extends Omit<FontAwesomeIconProps, 'icon' | 'animation'> {
  icon: IconProp | string | [string, string];
  animation?: IconAnimation;
  color?: string;
  fixedWidth?: boolean;
}

const PREFIX: Record<string, 'fas' | 'far' | 'fab'> = {
  fas: 'fas',
  far: 'far',
  fab: 'fab',
  'fa-solid': 'fas',
  'fa-regular': 'far',
  'fa-brands': 'fab',
};

const normalizeIcon = (icon: LibIconProps['icon']): IconProp => {
  if (Array.isArray(icon)) {
    return icon as IconProp;
  }

  if (typeof icon === 'string') {
    const parts = icon.trim().split(/\s+/);

    if (parts.length >= 2 && PREFIX[parts[0]]) {
      const name = parts[1].replace(/^fa-/, '');
      return [PREFIX[parts[0]], name] as IconProp;
    }

    return ['fas', icon.replace(/^fa-/, '')] as IconProp;
  }

  return icon as IconProp;
};

const LibIcon: React.FC<LibIconProps> = ({ icon, animation, ...props }) => {
  const animationProps = {
    spin: animation === 'spin',
    spinPulse: animation === 'spinPulse',
    spinReverse: animation === 'spinReverse',
    pulse: animation === 'pulse',
    beat: animation === 'beat',
    fade: animation === 'fade',
    beatFade: animation === 'beatFade',
    bounce: animation === 'bounce',
    shake: animation === 'shake',
  };

  return <FontAwesomeIcon icon={normalizeIcon(icon)} {...animationProps} {...props} />;
};

export default LibIcon;
