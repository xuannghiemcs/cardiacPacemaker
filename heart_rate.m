function [av_hrt max_threshold min_threshold count hrt_intrv] = heart_rate(hrt_data,time,neighbor,threshold)
av_hrt = 0;
max_threshold = 0;
min_threshold = 0;
diff = 0;
diff1 = 0;
len_threshold = .9*threshold;
count = 0;
% hrt_data = detrend(hrt_data);
i = 2;
heart_peak = [];
I = [];
prev_max = 0;
prev_min = 0;
sub_neigh = 0;
plot(time,hrt_data(:,1),'b')

if size(hrt_data,2) > 1
hold on
plot(time,hrt_data(:,2),'r')
hold off

end 
while i <= length(hrt_data)
    if i + neighbor - sub_neigh<=length(hrt_data)
        if i+neighbor - sub_neigh>=length(hrt_data)
            sub_neigh = sub_neigh + 1;
        end
        if hrt_data(i) >= threshold && hrt_data(i-1) < threshold
            hrt_max = max(hrt_data(i:i+neighbor- sub_neigh));
            if i-floor((neighbor- sub_neigh)/2)-300 < 1
                diff = -(i-floor((neighbor- sub_neigh)/2)-300)+1;
            end
            if i+floor((neighbor-sub_neigh)/2)+300 > length(hrt_data)
                diff1 = i+floor((neighbor-sub_neigh)/2)+300 - length(hrt_data);
            end
            hrt_min = min(hrt_data(i-floor((neighbor- sub_neigh)/2)-300+diff:...
                i+floor((neighbor-sub_neigh)/2)+300 - diff1));
            diff = 0;
            diff1 = 0;
            if hrt_max - hrt_min >= len_threshold && prev_max ~= hrt_max && prev_min ~= hrt_min
                prev_max = hrt_max;
                prev_min = hrt_min;
                max_threshold = max_threshold + prev_max;
                min_threshold = min_threshold + prev_min;
                count = count + 1;
                [heart_peak(end+1) I(end+1)] = max(hrt_data(i:i+neighbor- sub_neigh));
                I(end) = I(end) + i - 1;
                
                if length(I) > 1
                    k = 0;
                    b = 0;
                    if time(I(end)) - time(I(end-1)) <= .66 
                        [b, k] = min(heart_peak(end-1:end));
                        k = k + length(I)-2;
                        I(k) = [];
                        heart_peak(k) = [];
                    end
                end
                i = i + floor((neighbor-sub_neigh)/2);
                hold on
                plot(time(I(end)),heart_peak(end),'r*')
                hold off
                pause(.01)
                
            end
        end
    end
    i = i + 1;
end
% hold off

hrt_intrv = 0;
if length(I) > 1
    hrt_rate = zeros(1,length(I) - 1);
    for i = 1:length(I) - 1
        hrt_rate(i) = 1/(time(I(i+1)) - time(I(i)));
        hrt_intrv = hrt_intrv + (time(I(i+1)) - time(I(i)))/2;
    end
    av_hrt = mean(hrt_rate*60);
    hrt_intrv = hrt_intrv/(length(I) - 1);
     display(av_hrt)
end

end