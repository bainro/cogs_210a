clear; close all; clc;

%fix step size
dt = 0.001;
%parameter 
ntrials = 500; %NUMBER OF RUNS
ndt = 0.5; %NON-DECISION TIME
sd = 1;   %THIS IS VARIABILITY WITHIN THE WALK.  KEEP FIXED AT 1. 
nsteps = 2500; %MAX LENGTH OF WALK.  INCREASE TILL WARNING GOES AWAY
criterion = 1; %CORRECT BOUNDARY LOCATION, INCORRECT IS ZERO 
beta = 0.9; % NORMALIZED BIAS
bias = beta*criterion; %ACTUAL BIAS
%set random number seed 
rng(19680104);
%OUTPUT VARIABLES
sample = zeros(1,nsteps+1);   %This is a single random draw from normal distribution
path = zeros(ntrials,nsteps+1); %This is all the random walks
rt = zeros(ntrials,1);  %These are the rts across trials 
correct = zeros(ntrials,1); %This is accuracy data. ZERO IS WRONG, ONE IS RIGHT
%LOOP OVER ntrials.  
for j = 1:ntrials
    goodpath = 0;
    while goodpath == 0
        drawn_mu = unifrnd(0.2,0.3,[1,1]);
        draw = normrnd(drawn_mu*dt,sd*sqrt(dt),[1,nsteps]);  %DRAW A WALK
        sample(1) = bias; %START AT BIAS
        sample(2:nsteps+1) = draw; 
        walk = sample;%cumsum(sample); %SUM THE WALK.   
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

%compute accuracy
accuracy = mean(correct);  %COMPUTER FRACTION CORRECT
%convert rt to milliseconds
rt = rt*dt;
%plot all the random walks. 
figure
plot(path');
xlabel('Time')
ylabel('Evidence')
title('1')
set(gca,'YLim',[-0.5 criterion+0.5])
%Make a histogram of all random walks. 
figure  
bins = linspace(0,2,40);  
hist(rt,bins);
xlabel('Response Time')
ylabel('Number of Trials')
title('All Trials 1')
%Make a histogram separating correct from incorrect 
errorrt = rt(find(correct == 0));  % THIS IS JUST THE INCORRECT TRIALS
correctrt = rt(find(correct == 1)); %THIS IS JUST THE CORRECT TRIALS
figure
[n1,x] = hist(errorrt, bins); 
[n2,x] = hist(correctrt, bins);
h = bar(x,[n1; n2]);
legend('Error', 'Correct');

xlabel('Response Time')
ylabel('Number of Trials')
avg_time = mean(errorrt)
title(append('Correct vs Error Trials 1', num2str(avg_time)))
