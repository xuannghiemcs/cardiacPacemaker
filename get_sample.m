function [data time] = get_sample(ai,sampleRate,duration)
set(ai, 'SampleRate', sampleRate);
set(ai, 'SamplesPerTrigger', sampleRate*duration);
start(ai);

[data time] = getdata(ai);

end