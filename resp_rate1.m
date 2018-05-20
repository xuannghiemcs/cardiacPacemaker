function [av_resp count neighbor_peak min_threshold] = resp_rate1(resp_data,time,threshold,neighbor,sampling)
resp_data = resp_data - mean(resp_data);
av_resp = 0;
count = 0;
i = 2;
sub_neigh = 0;
res_peak = [];
I = [];
min_dist = [];
neighbor_peak = 0;
min_threshold = 0;

plot(time,resp_data,'b')
hold on
plot(time,ones(1,length(time))*threshold,'r--')
neighbor1 = floor(neighbor/1);
while i <=length(resp_data)
    if i + neighbor - sub_neigh<=length(resp_data)
        if resp_data(i-sub_neigh) >= threshold && resp_data(i+neighbor-sub_neigh)-resp_data(i-sub_neigh)>0 %&& mean(resp_data(i-sub_neigh:i+neighbor1-sub_neigh)) >= threshold && mean(resp_data(i-1-sub_neigh:i-1+neighbor1-sub_neigh))<threshold
            index_1 = i;
            if i+neighbor - sub_neigh>=length(resp_data)
                sub_neigh = sub_neigh + 1;
            end
            i = i + 1;
            sub_neigh1 = 0;
            
            while i <=length(resp_data)
                if i + neighbor - sub_neigh1<=length(resp_data)
                    if i+neighbor - sub_neigh1>=length(resp_data)
                            sub_neigh1 = sub_neigh1 + 1;
                        end
                    if resp_data(i-sub_neigh1) <= threshold && resp_data(i+neighbor-sub_neigh)-resp_data(i-sub_neigh1)<0 ...
                            %&& mean(resp_data(i-sub_neigh1:i+neighbor1-sub_neigh1)) <= threshold && mean(resp_data(i-1-sub_neigh1:i-1+neighbor1-sub_neigh1))>threshold
                        index_2 = i;
%                         if i+neighbor - sub_neigh1>=length(resp_data)
%                             sub_neigh1 = sub_neigh1 + 1;
%                         end
                        [res_peak(end+1) I(end+1)] = max(resp_data(index_1:index_2));
                        I(end) = I(end)+index_1 - 1;
                        plot(time(I(end)),res_peak(end),'g*')
                        pause(.01)
                        min_dist(end + 1) = index_2 - index_1;
                        i = i + neighbor - sub_neigh1;
                        break;
                    end
                    
                end
                i = i + sampling;
                if i+neighbor - sub_neigh1>=length(resp_data)
                    sub_neigh1 = sub_neigh1 + 1;
                end
%                 if i == length(resp_data)-1 && mean(resp_data(i-1-sub_neigh1:i-1+neighbor-sub_neigh1))>threshold
%                     index_2 = i;
%                     [res_peak(end+1) I(end+1)] = max(resp_data(index_1:index_2));
%                     I(end) = I(end)+index_1 - 1;
%                     min_dist(end + 1) = index_2 - index_1;
%                     
%                 end
            end
        end
    end
    i = i + sampling;
end


neighbor_peak = max(min_dist);
min_threshold = min(res_peak);


plot(time,ones(1,length(time))*(min_threshold - min_threshold/2),'k--')
pause(1)
hold off

if length(I) > 1
    respirator_rate = zeros(1,length(I) - 1);
    for i = 2:length(I)
        respirator_rate(i-1) = 1/(time(I(i)) - time(I(i-1)));
    end
    av_resp = mean(respirator_rate*60);
    count = length(respirator_rate);
    display((av_resp))
end

end
