clear; close all; clc;

%%
%fix step size
dt = 0.001;
%parameter 
ndt = 0.5; %NON-DECISION TIME
mu = 0.5;  %BY CONVENTION MU MUST BE POSITIVE 
sd = 1;   %THIS IS VARIABILITY WITHIN THE WALK.  KEEP FIXED AT 1. 
nsteps = 2500; %MAX LENGTH OF WALK.  INCREASE TILL WARNING GOES AWAY
ntrials = 500; %NUMBER OF RUNS
criterion = 1; %CORRECT BOUNDARY LOCATION, INCORRECT IS ZERO 
beta = 0.5; % NORMALIZED BIAS
bias = beta*criterion; %ACTUAL BIAS
total_err_pr = 0; % keep running sum of err probability
total_err_rt = 0; % use total_err_pr to normalize this value
%set random number seed 
rng(19680104);
%OUTPUT VARIABLES
sample = zeros(1,nsteps+1);   %This is a single random draw from normal distribution
path = zeros(ntrials,nsteps+1); %This is all the random walks
rt = zeros(ntrials,1);  %These are the rts across trials 
correct = zeros(ntrials,1); %This is accuracy data. ZERO IS WRONG, ONE IS RIGHT

figure

% loop over all 100 samples of drift rate (i.e. mu)
for i = 1:100
    sampled_mu = normrnd(mu,0.1,[1,1])
    %LOOP OVER ntrials.  
    for j = 1:ntrials
        goodpath = 0;
        while goodpath == 0
            draw = normrnd(sampled_mu*dt,sd*sqrt(dt),[1,nsteps]);  %DRAW A WALK
            sample(1) = bias; %START AT BIAS
            sample(2:nsteps+1) = draw; 
            walk = cumsum(sample); %SUM THE WALK.   
            crossbnd = find((walk > criterion) |(walk < 0)); %TEST BOTH BOUNDARIES  
            if ~isempty(crossbnd) %TEST IF IT CROSSED ONE OF THE BOUNDARIES AT LEAST
                goodpath = 1; %WALK IS GOOD, SET TO 1 TO EXIT WHILE LOOP
                path(j,:) = walk; %SAVE THE WALK
            else
                display('Bad Walk') %NOTIFY BAD WALK AND DRAW AGAIN LOWER
            end;
        end;
        rt(j) = crossbnd(1);  %RT IS FIRST CROSSING
        if path(j,rt(j)) > criterion  %TEST IF CORRECT
            path(j,rt(j):end) = criterion; %SET THE REST OF WALK TO BOUNDARY
            correct(j) = 1; %INDICATE CORRECT TRIAL
        else %TRIALIS INCORRECT
            path(j,rt(j):end) = 0; %SET THE REST OF WALK TO ZERO. 
        end; 
        %Add Non-decision time
        rt(j) = rt(j) + ndt/dt;	
    end
    % need to weight average incorrect response times by relative probabilities of incorrect
    %convert rt to milliseconds
    rt = rt*dt;
    errorrt = rt(find(correct == 0));
    % this trial's avg
    avg_err_rt = mean(errorrt);
    err_pr = 1 - mean(correct);
    total_err_rt = total_err_rt + avg_err_rt * err_pr;
    total_err_pr = total_err_pr + err_pr;
    hold on
    bins = linspace(0,2,40);
    [n1,x] = hist(errorrt, bins); 
    h = bar(x, n1);
end

% avg now over all trials
% weighed mean err response time!
avg_err_rt = total_err_rt / total_err_pr;
xline(avg_err_rt,'--b');
xlabel('Response Time')
ylabel('Number of Trials')
title('Error Trial RTs')
