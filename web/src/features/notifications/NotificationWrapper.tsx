import { useNuiEvent } from '../../hooks/useNuiEvent';
import { toast, Toaster } from 'react-hot-toast';
import ReactMarkdown from 'react-markdown';
import { Box, Center, createStyles, Group, keyframes, RingProgress, Stack, Text, ThemeIcon } from '@mantine/core';
import type { Sx } from '@mantine/core';
import React, { useState, CSSProperties } from 'react';
import tinycolor from 'tinycolor2';
import type { NotificationProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';
import LibIcon from '../../components/LibIcon';
import type { ToastPosition } from 'react-hot-toast';
import { typeColors } from '../../theme';

const useStyles = createStyles((theme) => ({
  container: {
    width: 300,
    height: 'fit-content',
    backgroundColor: theme.other.vuSurface,
    color: theme.other.vuText,
    padding: 12,
    borderRadius: theme.radius.sm,
    fontFamily: 'Roboto, sans-serif',
    boxShadow: theme.shadows.sm,
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },
  title: {
    fontWeight: 500,
    lineHeight: 'normal',
  },
  description: {
    fontSize: 12,
    color: theme.other.vuMuted,
    fontFamily: 'Roboto, sans-serif',
    lineHeight: 'normal',
  },
  descriptionOnly: {
    fontSize: 14,
    color: theme.other.vuMuted,
    fontFamily: 'Roboto, sans-serif',
    lineHeight: 'normal',
  },
}));

const createAnimation = (from: string, to: string, visible: boolean) =>
  keyframes({
    from: {
      opacity: visible ? 0 : 1,
      transform: `translate${from}`,
    },
    to: {
      opacity: visible ? 1 : 0,
      transform: `translate${to}`,
    },
  });

const getAnimation = (visible: boolean, position: string) => {
  const animationOptions = visible ? '0.2s ease-out forwards' : '0.4s ease-in forwards';
  let animation: { from: string; to: string };

  if (visible) {
    animation = position.includes('bottom')
      ? { from: 'Y(30px)', to: 'Y(0px)' }
      : { from: 'Y(-30px)', to: 'Y(0px)' };
  } else if (position.includes('right')) {
    animation = { from: 'X(0px)', to: 'X(100%)' };
  } else if (position.includes('left')) {
    animation = { from: 'X(0px)', to: 'X(-100%)' };
  } else if (position === 'top-center') {
    animation = { from: 'Y(0px)', to: 'Y(-100%)' };
  } else if (position === 'bottom-center') {
    animation = { from: 'Y(0px)', to: 'Y(100%)' };
  } else {
    animation = { from: 'X(0px)', to: 'X(100%)' };
  }

  return `${createAnimation(animation.from, animation.to, visible)} ${animationOptions}`;
};

const durationCircle = keyframes({
  '0%': { strokeDasharray: `0, ${15.1 * 2 * Math.PI}` },
  '100%': { strokeDasharray: `${15.1 * 2 * Math.PI}, 0` },
});

const resolveTypeColor = (type?: string) => {
  if (!type) return typeColors.info;
  return typeColors[type as keyof typeof typeColors] ?? typeColors.info;
};

const Notifications: React.FC = () => {
  const { classes } = useStyles();
  const [, setToastKey] = useState(0);

  useNuiEvent<NotificationProps>('notify', (data) => {
    if (!data.title && !data.description) return;

    const toastId = data.id?.toString();
    const duration = data.duration || 3000;
    let position = (data.position || 'top-right') as ToastPosition | 'top' | 'bottom';
    data.showDuration = data.showDuration !== undefined ? data.showDuration : true;

    if (toastId) setToastKey((prev) => prev + 1);

    if (position === 'top') position = 'top-center';
    if (position === 'bottom') position = 'bottom-center';

    const typeColor = resolveTypeColor(data.type);
    const hideIcon = data.hideIcon === true || data.icon === false;

    if (!hideIcon && !data.icon) {
      switch (data.type) {
        case 'error':
          data.icon = 'circle-xmark';
          break;
        case 'success':
          data.icon = 'circle-check';
          break;
        case 'warning':
          data.icon = 'circle-exclamation';
          break;
        default:
          data.icon = 'circle-info';
          break;
      }
    }

    let iconColor: string;
    if (!data.iconColor) {
      iconColor = typeColor;
    } else {
      iconColor = tinycolor(data.iconColor).toRgbString();
    }

    const durationColor = data.durationColor
      ? tinycolor(data.durationColor).toRgbString()
      : iconColor;

    const shadow =
      data.shadow === false
        ? 'none'
        : typeof data.shadow === 'string'
          ? data.shadow
          : undefined;

    toast.custom(
      (t) => (
        <Box
          className={classes.container}
          sx={{
            animation: getAnimation(t.visible, position as string),
            ...(data.backgroundColor ? { backgroundColor: data.backgroundColor } : {}),
            ...(data.color ? { color: data.color } : {}),
            ...(data.width !== undefined ? { width: data.width } : {}),
            ...(data.padding !== undefined ? { padding: data.padding } : {}),
            ...(data.borderRadius !== undefined ? { borderRadius: data.borderRadius } : {}),
            ...(data.borderColor ? { borderColor: data.borderColor } : {}),
            ...(data.borderWidth !== undefined ? { borderWidth: data.borderWidth } : {}),
            ...(data.opacity !== undefined ? { opacity: data.opacity } : {}),
            ...(data.fontFamily ? { fontFamily: data.fontFamily } : {}),
            ...(shadow !== undefined ? { boxShadow: shadow } : {}),
            ...(data.style || {}),
          } as Sx}
        >
          <Group noWrap spacing={12} align={data.alignIcon || 'center'}>
            {!hideIcon && data.icon && (
              <>
                {data.showDuration ? (
                  <RingProgress
                    key={toastId ? `${toastId}-${Date.now()}` : undefined}
                    size={data.iconSize ? data.iconSize + 6 : 38}
                    thickness={2}
                    sections={[{ value: 100, color: durationColor }]}
                    style={{ alignSelf: !data.alignIcon || data.alignIcon === 'center' ? 'center' : 'start' }}
                    styles={{
                      root: {
                        '> svg > circle:nth-of-type(2)': {
                          animation: `${durationCircle} linear forwards reverse`,
                          animationDuration: `${duration}ms`,
                        },
                        margin: -3,
                      },
                    }}
                    label={
                      <Center>
                        <ThemeIcon
                          color={iconColor}
                          radius="xl"
                          size={data.iconSize || 32}
                          variant="light"
                        >
                          <LibIcon icon={data.icon!} fixedWidth color={iconColor} animation={data.iconAnimation} />
                        </ThemeIcon>
                      </Center>
                    }
                  />
                ) : (
                  <ThemeIcon
                    color={iconColor}
                    radius="xl"
                    size={data.iconSize || 32}
                    variant="light"
                  >
                    <LibIcon icon={data.icon!} fixedWidth color={iconColor} animation={data.iconAnimation} />
                  </ThemeIcon>
                )}
              </>
            )}
            <Stack spacing={0} style={{ flex: 1, minWidth: 0 }}>
              {data.title && (
                <Text
                  className={classes.title}
                  style={{
                    color: data.color,
                    fontSize: data.titleFontSize,
                    fontWeight: data.titleFontWeight as CSSProperties['fontWeight'],
                    fontFamily: data.fontFamily,
                  }}
                >
                  {data.title}
                </Text>
              )}
              {data.description && (
                <Box
                  className={!data.title ? classes.descriptionOnly : classes.description}
                  style={{
                    color: data.descriptionColor,
                    fontSize: data.descriptionFontSize,
                    fontFamily: data.fontFamily,
                  }}
                  sx={{ '& p': { margin: 0 } }}
                >
                  <ReactMarkdown components={MarkdownComponents}>{data.description}</ReactMarkdown>
                </Box>
              )}
            </Stack>
          </Group>
        </Box>
      ),
      {
        id: toastId,
        duration,
        position: position as ToastPosition,
      }
    );
  });

  return <Toaster position="top-right" reverseOrder={false} gutter={8} />;
};

export default Notifications;
