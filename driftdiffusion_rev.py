#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr  7 18:45:20 2020

@author: ramesh
"""

#%%
#IMPORT YOUR MODULES
import numpy as np
from matplotlib import pyplot as plt
#fix step size 
dt = 0.001
#SET PARMETERS 
ndt = 0.5;
mu = 0.5 #BY CONVENTION MU MUST BE POSITIVE FOR CORRECT
sd = 1 #VARIABILITY WITHIN TRIAL
nsteps = 2500 # MAXIMUM LENGTH OF WALK
ntrials = 500 #NUMBER OF TRIALS IN EXPERIMENT
criterion = 1 #UPPER BOUNDARY FOR CORRECT RESPONSES 
beta = 0.5 #NORMALIZED BIAS
bias = beta*criterion 
#SET RANDOM NUMBER SEED 
np.random.seed(19680205)
# OUTPUT VARIABLES
sample = np.zeros(nsteps+1)  #This is a single random draw from normal distribution
path = np.zeros((ntrials,nsteps+1)) #This is all the random walks
rt = np.zeros((ntrials)) #These are the rts across trials 
correct = np.zeros((ntrials)) #This is accuracy data. ZERO IS WRONG, ONE IS RIGHT
for j in range(ntrials):
    goodpath = 0 # variable to test if the path is good. 
    while goodpath == 0: #WILL REPEAT RANDOM WALK UNTIL A GOOD WALK
        draw = np.random.normal(mu*dt,sd*np.sqrt(dt),nsteps) #DRAW A WALK
        sample[0] = bias #START AT BIAS
        sample[1:] = draw
        walk = np.cumsum(sample) #SUM THE WALK.
        crossbnd = np.where((walk > criterion) | (walk < 0)) #TEST BOTH BOUNDARIES
        if np.size(crossbnd) != 0: #DETECT THAT IT CROSSED A BOUNDARY
            goodpath = 1 #SET GOODPATH TO 1 TO EXIT WHILE LOOP
            path[j,:] = walk # SAVE THE WALK
        else:
            print("Bad Walk")
    rt[j] = crossbnd[0][0]  #FIND FIRST CROSSING POINT 
    rtindex = rt[j].astype(int)
    if path[j,rtindex] > criterion: #DETECT CORRECT TRIALS
        path[j,rtindex:] = criterion #STOP THE WALK AT BOUNDARY
        correct[j] = 1 #
    else: #INCORRECT TRIAL
        path[j,rtindex:] = 0 #STOP WALK AT LOWER BOUNDARY
    #add non-decision time           
    rt[j] = rt[j]+ndt/dt            
#COMPUTE ACCURACY
accuracy = np.mean(correct)
#CONVERT RT TO SECONDS
rt = rt*dt
#PLOT ALL PATHS
for j in range(ntrials):
    plt.plot(path[j,:])

plt.xlabel('Time')
plt.ylabel('Evidence')
#MAKE A HISTOGRAM OF ALL TRIALS
plt.figure()  
bins = np.linspace(0,2,40)  
plt.hist(rt,bins)
plt.xlabel('Response Time')
plt.ylabel('Number of Trials')
plt.title('All Trials')
#MAKE A HISTOGRAM SEPARATING CORRECT FROM INCORRECT
errorrt = rt[np.where(correct == 0)]
correctrt = rt[np.where(correct == 1)]
plt.figure()
plt.hist([errorrt,correctrt], bins, alpha=0.5, label=['Error', 'Correct'])

plt.legend(loc='upper right')
plt.xlabel('Response Time')
plt.ylabel('Number of Trials')
plt.title('Correct vs Error Trials')



