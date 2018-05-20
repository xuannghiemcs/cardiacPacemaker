function [av_hrt] = adaptive_hr(hrt_data,time,neighbor,max_threshold,min_threshold)
av_hrt = 0;
diff = 0;
diff1 = 0;
len_threshold = .7*(max_threshold - min_threshold);
max_threshold = .5*max_threshold;
i = 2;
heart_peak = [];
I = [];
prev_max = 0;
prev_min = 0;
sub_neigh = 0;
count = 0;


plot(time,hrt_data,'b')
while i <= length(hrt_data)
    if i + neighbor - sub_neigh<=length(hrt_data)
        if i+neighbor - sub_neigh>=length(hrt_data)
            sub_neigh = sub_neigh + 1;
        end
        if hrt_data(i) >= max_threshold && hrt_data(i-1) < max_threshold
            hrt_max = max(hrt_data(i:i+neighbor- sub_neigh));
            if i-floor((neighbor- sub_neigh)/2)-300 < 1
                diff = -(i-floor((neighbor- sub_neigh)/2)-300)+1;
            end
            if i+floor((neighbor-sub_neigh)/2)+300 > length(hrt_data)
                diff = i+floor((neighbor-sub_neigh)/2)+300 - length(hrt_data);
            end
            hrt_min = min(hrt_data(i-floor((neighbor- sub_neigh)/2)-300+diff:i+floor((neighbor-sub_neigh)/2)+300 - diff));
            diff = 0;
            if hrt_max - hrt_min >= len_threshold && prev_max ~= hrt_max && prev_min ~= hrt_min
                prev_max = hrt_max;
                prev_min = hrt_min;
                [heart_peak(end+1) I(end+1)] = max(hrt_data(i:i+neighbor- sub_neigh));
                I(end) = I(end) + i;
                i = i + floor((neighbor-sub_neigh)/2);
                hold on
                plot(time(I(end)),heart_peak(end),'*')
                % hold off
                pause(.01)
                
            end
        end
    end
    i = i + 1;
end
hold off

if length(I) > 1
    hrt_rate = zeros(1,length(I) - 1);
    for i = 1:length(I) - 1
        hrt_rate(i) = 1/(time(I(i+1)) - time(I(i)));
    end
    av_hrt = mean(hrt_rate*60);
    display(av_hrt)
end

end

