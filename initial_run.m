function [store_HR store_maxHR_threshold store_minHR_threshold store_resp av_resp_threshold av_resp_neigh_peak] = initial_run...
    (ai,num_samples,duration,check,neighbor_hr,neighbor_resp)
av_hrt = 0;
maxHR_threshold = 0;
minHR_threshold = 0;
count_total = 0;
store_maxHR_threshold = 0;
store_minHR_threshold = 0;
store_HR = 0;
count = 0;
sampling = 60;

av_resp_threshold = 0;
av_resp_neigh_peak = 0;
count1 = 0;
count_total1 = 0;
store_resp = 0;

activate_hr = -1;
activate_resp = -1;


% checks for normality of condition
if check == 0
    activate_hr = 1;
    activate_resp = 1;
    
elseif check == 1
    activate_hr = 1;
    activate_resp = 0;
elseif check == -1
    activate_hr = 0;
    activate_resp = 1;
    
else
    display('Incorrect Condition')
end


% vital_data = [ai.b(:,2) ai.resp_data];
% time = ai.time;
% vital_data = detrend(vital_data);

for i = 1:5
%     [vital_data time] = get_sample(ai,num_samples/duration,duration);
    
 vital_data = ai.vital_data;
time = ai.time;
vital_data = detrend(vital_data);
filename = ['test_data' num2str(i-1) '.mat'];
ai = load(filename);


    if activate_hr == 1
        threshold = .3*max(vital_data(:,1)); % channel 1 heart_rate
        [av_hrt maxHR_threshold minHR_threshold count] = heart_rate...
            ([vital_data(:,1) vital_data(:,3)],time,neighbor_hr,threshold);
        count_total = count_total + count;
        store_maxHR_threshold = store_maxHR_threshold + maxHR_threshold;
        store_minHR_threshold = store_minHR_threshold + minHR_threshold;
        store_HR = av_hrt*(count - 1) + store_HR;
    end
    
    if activate_resp == 1
        threshold = 0.01;
        [av_resp count neighbor_peak min_threshold] = resp_rate1...
            (vital_data(:,2),time,threshold,neighbor_resp,sampling);
        av_resp_threshold = av_resp_threshold*count1 + min_threshold;
        av_resp_neigh_peak = av_resp_neigh_peak*count1 + neighbor_peak;
        count1 = count1 + 1;
        av_resp_threshold = av_resp_threshold/count1;
        av_resp_neigh_peak = av_resp_neigh_peak/count1;
        count_total1 = count_total1 + count;
        store_resp = store_resp + av_resp*count;
    end
    

   
end

if activate_hr == 1
    store_HR = store_HR/(count_total-5);
    store_maxHR_threshold = store_maxHR_threshold/count_total;
    store_minHR_threshold = store_minHR_threshold/count_total;
    display(store_HR)
end

if activate_resp == 1
    store_resp = store_resp/count_total1;
    display(store_resp)
end

end