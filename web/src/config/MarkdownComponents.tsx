import { Title } from '@mantine/core';
import type { Components } from 'react-markdown';

const MarkdownComponents: Components = {
  h1: ({ node: _node, ...props }) => <Title order={1} {...props} />,
  h2: ({ node: _node, ...props }) => <Title order={2} {...props} />,
  h3: ({ node: _node, ...props }) => <Title order={3} {...props} />,
};

export default MarkdownComponents;
