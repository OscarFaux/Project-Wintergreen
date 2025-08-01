import { useBackend } from 'tgui/backend';
import { Box, LabeledList, Section } from 'tgui-core/components';

import type { Data } from './types';

export const ResleevingConsoleStatus = (props) => {
  const { data } = useBackend<Data>();
  const { pods, spods, sleevers } = data;
  return (
    <Section title="Status">
      <LabeledList>
        <LabeledList.Item label="Pods">
          {pods?.length ? (
            <Box color="good">{pods.length} connected</Box>
          ) : (
            <Box color="bad">None connected!</Box>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="SynthFabs">
          {spods?.length ? (
            <Box color="good">{spods.length} connected</Box>
          ) : (
            <Box color="bad">None connected!</Box>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Sleevers">
          {sleevers?.length ? (
            <Box color="good">{sleevers.length} Connected</Box>
          ) : (
            <Box color="bad">None connected!</Box>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
