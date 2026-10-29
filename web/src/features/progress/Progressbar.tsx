import React from 'react';
import { Box, createStyles, Text } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFade from '../../transitions/ScaleFade';
import type { ProgressbarProps } from '../../typings';

const useStyles = createStyles((theme) => ({
  wrapper: {
    width: '100%',
    height: '20%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    bottom: 0,
    position: 'absolute',
  },
  container: {
    position: 'relative',
    width: 350,
    height: 45,
    borderRadius: theme.radius.sm,
    backgroundColor: theme.other.vuSurfaceAlt,
    overflow: 'hidden',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },
  bar: {
    position: 'absolute',
    inset: 0,
    width: 0,
    height: '100%',
    backgroundColor: theme.colors[theme.primaryColor][theme.fn.primaryShade()],
  },
  label: {
    position: 'absolute',
    inset: 0,
    zIndex: 1,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    margin: 0,
    padding: '0 12px',
    maxWidth: '100%',
    textOverflow: 'ellipsis',
    overflow: 'hidden',
    whiteSpace: 'nowrap',
    fontSize: 18,
    fontWeight: 500,
    color: theme.other.vuText,
    textShadow: '0 1px 2px rgba(0,0,0,0.65)',
    pointerEvents: 'none',
  },
}));

const Progressbar: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = React.useState(false);
  const [label, setLabel] = React.useState('');
  const [duration, setDuration] = React.useState(0);

  useNuiEvent('progressCancel', () => setVisible(false));

  useNuiEvent<ProgressbarProps>('progress', (data) => {
    setVisible(true);
    setLabel(data.label);
    setDuration(data.duration);
  });

  return (
    <Box className={classes.wrapper}>
      <ScaleFade visible={visible} onExitComplete={() => fetchNui('progressComplete')}>
        <Box className={classes.container}>
          <Box
            className={classes.bar}
            onAnimationEnd={() => setVisible(false)}
            sx={{
              animation: 'progress-bar linear forwards',
              animationDuration: `${duration}ms`,
            }}
          />
          <Text className={classes.label}>{label}</Text>
        </Box>
      </ScaleFade>
    </Box>
  );
};

export default Progressbar;
