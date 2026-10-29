import { MantineProvider } from '@mantine/core';
import Notifications from './features/notifications/NotificationWrapper';
import CircleProgressbar from './features/progress/CircleProgressbar';
import Progressbar from './features/progress/Progressbar';
import TextUI from './features/textui/TextUI';
import { theme } from './theme';

const App: React.FC = () => {
  return (
    <MantineProvider withNormalizeCSS withGlobalStyles theme={{ ...theme }}>
      <Progressbar />
      <CircleProgressbar />
      <Notifications />
      <TextUI />
    </MantineProvider>
  );
};

export default App;
