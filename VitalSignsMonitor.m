close all
clear all

check = 0; 
norm_hr = false; 
norm_resp = false;  

neighbor_hr = 700;
neighbor_resp = 400;

% ai = load('comboned.mat');
ai = load('test_data0.mat');

% ai = analoginput('nidaq', 'Dev3'); % add device
% chans = addchannel(ai, [0 1]);   % change channel
                                 % first channel heart data
                                 % second channel respiratory data
num_samples = 15000; % 15000 samples
duration = 3;  % 3 sec duration

 % lower threshold if cannot detect peaks
av_hrt = 0;
av_resp = 0;
maxHR_threshold = 0; 
minHR_threshold = 0;
count = 0;
store_HR = 0;
store_maxHR_threshold = 0;
store_minHR_threshold = 0;

av_resp_threshold = 0;
av_resp_neigh_peak = 0;

inf_loop = true;

% vital_data = [ai.b(:,2) ai.resp_data];
% time = ai.time;
% vital_data = detrend(vital_data);

while inf_loop
    [store_HR store_maxHR_threshold store_minHR_threshold store_resp av_resp_threshold av_resp_neigh_peak] = initial_run...
        (ai,num_samples,duration,check,neighbor_hr,neighbor_resp);
    
    if store_HR < 120 && store_HR > 60
        % condition -1
        norm_hr = true;
    end
    if store_resp < 32 && store_resp > 10
        % condition 1
        norm_resp = true;
    end
    if store_HR > 120 && store_HR < 60 && store_resp > 30 && store_resp < 10
        % condition 0
        norm_hr = false;
        norm_resp = false;
    end
    
    if norm_hr == true && norm_resp == false
        check = -1;
    elseif norm_resp == true && norm_hr == false
        check = 1;
    elseif norm_hr == false && norm_resp == false
        check = 0;
    else
        inf_loop = false;         
    end    
end

ai = load('comboned.mat');

%% Main Code
num_samples = 10000;
duration = 2;

count = 0;
count1 = 0;
last_time = 0;
stored_data = zeros(num_samples*5,2);
stored_time = zeros(1,num_samples*5);

p = 0;
while count < 2
%     [vital_data time] = get_sample(ai,num_samples/duration,duration);

vital_data = [ai.b(:,2) ai.resp_data];
time = ai.time;
vital_data = detrend(vital_data);
    

%     stored_data(count1*length(vital_data(:,1))+1:(count1+1)*length...
%         (vital_data(:,1))+1,:) = vital_data;
  
p = p + 10;
if p + 5000 > length(vital_data(:,1))
   break; 
end
    stored_data(p:p+5000,:) = vital_data(p:p+5000,:);
    
    
    time1(p:p+5000) = last_time + time(p:p+5000);
%     stored_time(count1*length(vital_data(:,1))+1:(count1+1)*length...
%         (vital_data(:,1))+1) = time;
%     last_time = time(end);
     [av_resp] = adapt_resp_rate(stored_data(1:p+5000,1),time1,av_resp_threshold-(av_resp_threshold/2),neighbor_resp,floor(av_resp_neigh_peak));
%     [av_hrt] = adaptive_hr(stored_data(1:(count1+1)*length...
%         (vital_data(:,1))+1,1),time,neighbor_hr,...
%         store_maxHR_threshold,store_minHR_threshold);
    
     %    [av_resp] = adapt_resp_rate(stored_data(1:p+5000,2),time1,av_resp_threshold-(av_resp_threshold/2),neighbor_resp,floor(av_resp_neigh_peak));
    [av_hrt] = adaptive_hr(stored_data(1:p+5000,1),time1,neighbor_hr,...
        .7*store_maxHR_threshold,.8*store_minHR_threshold);
    
    
    count1 = count1 + 1;
    if av_resp ~= 0 
        count = count + 1;
    end
end


 
inf_loop = true;
num_samples = 5000;
duration = 1;

while inf_loop
%     [vital_data time] = get_sample(ai,num_samples/duration,duration);
%     stored_data(count1*length(vital_data(:,1))+1:(count1+1)*length...
%         (vital_data(:,1))+1,:) = vital_data;
%     time = last_time + time;
%     stored_time(count1*length(vital_data(:,1))+1:(count1+1)*length...
%         (vital_data(:,1))+1) = time;
    
    p = p + 10;
if p + 5000 > length(vital_data(:,1))
   break; 
end
    stored_data(p:p+5000,:) = vital_data(p:p+5000,:);
    
    
    time1(p:p+5000) = last_time + time(p:p+5000);
    
    count1 = count1 + 1;
    
    [av_resp] = adapt_resp_rate(stored_data(1:p+5000,2),time1,av_resp_threshold-(av_resp_threshold/2),neighbor_resp,floor(av_resp_neigh_peak/3.5));
    [av_hrt] = adaptive_hr(stored_data(1:p+5000,1),time1,neighbor_hr,...
        .7*store_maxHR_threshold,.8*store_minHR_threshold);
    
    
    if count1 >= 10
        time = time - time(1);
        stored_data(1:length(vital_data(:,1)),:) = vital_data;
        stored_time(1:length(time)) = time;
        count1 = 1;
        
    end
    
end

