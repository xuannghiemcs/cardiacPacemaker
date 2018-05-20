function [av_resp] = adapt_resp_rate(resp_data,time,threshold,neighbor,neighbor_peak)
i = 2;
sub_neigh = 0;
res_peak = [];
I = [];
index_1 = [];
diff_peak = 0;
av_resp = 0;
resp_peak = 0;

plot(time,resp_data,'b')
hold on
plot(time,ones(1,length(time))*threshold,'r--')

while i <=length(resp_data)
    if i + neighbor - sub_neigh<=length(resp_data)
        if resp_data(i-sub_neigh) >= threshold && resp_data(i+neighbor-sub_neigh)-resp_data(i-sub_neigh)>0
            if i+neighbor - sub_neigh>=length(resp_data)
                sub_neigh = sub_neigh + 1;
            end
            index_1 = i;
            if index_1 + neighbor_peak > length(resp_data)
                diff_peak = index_1 + neighbor_peak - length(resp_data);
            else
                diff_peak = 0;
            end
            [res_peak(end+1) I(end+1)] = max(resp_data(index_1:index_1 + neighbor_peak- diff_peak));
            i = i + neighbor_peak - diff_peak;
            I(end) = I(end) + index_1 - 1;
            plot(time(I(end)),res_peak(end),'m*')
            pause(.01)
        end
    end
    i = i + 1;
end

hold off

if length(I) > 1
    respirator_rate = zeros(1,length(I) - 1);
    for i = 1:length(I) - 1
        respirator_rate(i) = 1/(time(I(i+1)) - time(I(i)));
    end
    av_resp = mean(respirator_rate*60);
    display(av_resp)
end

end
