%% About
% This script was created by Dr. Alexa Ruel for educational purposes in the context of the Project Seminar Course at the University of Hamburg and should not be used without direct authorization from Dr. Ruel
% Last updated on: April 24, 2024
% Email Dr. Ruel at alexa.ruel@uni-hambrug.de with any questions, concerns or to request permission to use this script outside the course.

% We have 4 conditions (common, oddball, rare, reversal-learning). We get 4
% averages (1 for each condition), then we averade those for all
% participants 

%%We sampled [collected data] at 500 Hz. That was then transfered to
%%1000Hz. 
%Rereferencing: FP2 was the reference electrode. 20  (P8) is wrong, she wrongly
%said that before. Rereferecing to the average of the mastoids TP9 and TP10

%% 1. Create Grand Average;

cd 'C:\Users\mirar\Desktop\ProjektseminarMatlabData'
% where data is saved (folder with last preprocessing step) 

for x = 1:3
    x= string(x); 
    disp(x)

subjects = [1:6];
% all the subject numbers have to be entered here

GrandAverageEEG = nan(length(subjects), 4, 63, 750); %Grandaverage on 4 dimensions: subjects, conditions, channels, time 


for i = 1 : length(subjects)
    EEG = pop_loadset([strcat(num2str(subjects(i)), '_08_ICAdone.set')]);  
    % change _07_ICAdone.set to the name of the file of the last preprocessing 

 %%
    EpochNames = {}; %this list is supposed to be empty

    
    for c = 1 : length(EEG.epoch)
        if EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "common" 
            EpochNames(c) = {'oddball_common'}; 
        elseif EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "rare"
             EpochNames(c) = {'oddball_rare'};
        elseif EEG.epoch(c).condition == "changepoint" && EEG.epoch(c).surprise == "common"
             EpochNames(c) = {'changepoint_common'};
        elseif EEG.epoch(c).condition == "changepoint" && EEG.epoch(c).surprise == "rare"
             EpochNames(c) = {'changepoint_rare'};
        end
    end

    %This is a Check! This takes all the epochs of the conditions and
    %prints them. There I should see the devide into 80 and 20% of the
    %oddball conditions suprise and common
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'oddball_common')))/length(EEG.epoch)) ' % stimuli of type oddball_common'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'oddball_rare')))/length(EEG.epoch)) ' % stimuli of type oddball_rare'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'reversal_common')))/length(EEG.epoch)) ' % stimuli of type reversal_common'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'reversal_rare')))/length(EEG.epoch)) ' % stimuli of type reversal_rare'])

    epochtrans2 = {'oddball_common' 'oddball_rare' 'reversal_common' 'reversal_rare'};

%%% from here: work on code, see comment below     
OBCOM = find (EpocNames == "oddball_common"); % also for 3 other variables create pls 

IndOBCOM = randsample(OBCOM, length ( ......))
    ...
    ...
    epochtrans2

%.... Create variables with lists with the ephocs from the respective
%condition, nummerically in a list. create code that say take random sample
%out of these lists with a number that is equal to the number in the rare
%list. save it. hint: function (find) has to be used within EpochNames to
%find which epochs condition correspond to which label. Also use randSample
%(oder so ähnlich) to random sample. 

epchtrans2 = ('oddball_common' 'oddball_rare' 'reversal_common' 'reversal_rare');
   
    for nc = 1 : length(epochtrans2)
        n_trials(i,nc) = sum(sum(strcmpi(EpochNames,epochtrans2{nc}))); 

        % save the current subject's data to GrandAverageEEG
        GrandAverageEEG(i,nc,:,:) = mean(EEG.data(:,:,strcmpi(EpochNames,epochtrans2{nc})),3);
    end

path = stract('C:\Users\mirar\Desktop\ProjektseminarMatlabData', x, '.mat'); 
save(path, "GrandAverageEEG")

end 

%Number of epochs from the rare trials should be >30. Also, number of rare
%and common trials should also not differ too much in theory. Thats why we
%reduce the number of the trials in commumn 1 and 3 (the commons) to the
%number of epochs from the 2nd and 4th collumn (rare trials) - we randomly
%choose the number of rare trials from the common trials. AFterwards, we
%statistically check if the chosen ephocs are representative for the whole
%many. 

%% 2. Plot Grand Average - with both conditions, and trial types shown
% The plot created in the following should be saved and labeled :).
close all;
hfig = figure;
hold on;

%the following code chooses the electrode of interest (For example Fz)
% I can find the corresponding number of the electrode in the eeg data information

%elec = 2; %Fz
%elec = 23; %Cz
elec = 12; %Pz

% if using more than one electrode... 


% Create electrode(s) by time point for ODDBALL_COMMON: 1 x num time points
OB_COMMON = GrandAverageEEG(:,1,elec,:); 
OB_COMMON = squeeze(mean(OB_COMMON,1)); % electrode(s) X time points (This is done across participants here)
%OB_COMMON = squeeze(mean(OB_COMMON,1)); %averaged across electrodes = 1 x
%time points (squeeze: make the 4 d matrix 2 d by deleting all the columns
%that only say 1)

% Create electrode(s) by time point for ODDBALL_RARE: 1 x num time points
OB_RARE = GrandAverageEEG(:,2,elec,:); 
OB_RARE = squeeze(mean(OB_RARE,1));
%OB_RARE = squeeze(mean(OB_RARE,1));

% Create electrode(s) by time point for REVERSAL_COMMON: 1 x num time points
REV_COMMON = GrandAverageEEG(:,3,elec,:);
REV_COMMON = squeeze(mean(REV_COMMON,1));
%REV_COMMON = squeeze(mean(REV_COMMON,1));

% Create electrode(s) by time point for REVERSAL_RARE: 1 x num time points
REV_RARE = GrandAverageEEG(:,4,elec,:); 
REV_RARE = squeeze(mean(REV_RARE,1));
%REV_RARE = squeeze(mean(REV_RARE,1));



plot (EEG.times, OB_COMMON,'b', EEG.times, OB_RARE, '--b', EEG.times, REV_COMMON, 'r', EEG.times, REV_RARE, '--r')
title(['EEG at ' EEG.chanlocs(elec).labels])
set(gca, 'YDir')
legend
xlabel('time'); ylabel('uV')
xlim([-200 1000]);
%do this 4 times for each of the conditions if you want 4 plots. colors: b
%blue, --b dashed blue, r red, --r dashed red; YDir - have the y axis
%normally and not reversely plotted

% The plot that opens is modifyable, for example through the edit Reiter.
% Add a legend and all if its not there yet. Adjust the scales of the
% y-axis so that it is the same for all plots of the different electrodes. 
%SAVE it :) as a matab figure and a jng. -> can still edit it and put it in
%a ppt. 

%% Difference Value Plots.
ob_diff = OB_RARE - OB_COMMON ; 
%ob_diff = squeeze(mean(ob_diff,1)); 

rev_diff = REV_RARE - REV_COMMON ; 
%rev_diff = squeeze(mean(rev_diff,1));

common_diff = REV_COMMON - OB_COMMON;
%common_diff = squeeze(mean(common_diff,1));

rare_diff = REV_RARE - OB_RARE; 
%rare_diff = squeeze(mean(rare_diff,1));

% condition difference values
plot (EEG.times, ob_diff, EEG.times, rev_diff)
title(['EEG at ' EEG.chanlocs(elec).labels]) 
set(gca, 'YDir')
legend
xlabel('time'); ylabel('EEG')


% trial type difference values
plot (EEG.times, common_diff, EEG.times, rare_diff)
title(['EEG at ' EEG.chanlocs(elec).labels])
set(gca, 'YDir')
legend
xlabel('time'); ylabel('EEG')


%% 3. Topographies

% ODDBALL COMMON
OB_COMMON_TOPO = GrandAverageEEG(:,1,:,:); 
OB_COMMON_TOPO = squeeze(mean(OB_COMMON_TOPO,1)); % squeezes the 4D matrix into a channels by timepoints matrix. So squeezes across all subjects (means)
OB_COMMON_TOPO = OB_COMMON_TOPO(1:63, ); % selects only the time range we are interested in for the topography (window of analysis)

%average the voltages across the channels
OB_COMMON_TOPO = mean(OB_COMMON_TOPO,2);

% change the size of the matrix
OB_COMMON_TOPO = OB_COMMON_TOPO';




% REVERSAL COMMON
REV_COMMON_TOPO = GrandAverageEEG(:,3,:,:);
REV_COMMON_TOPO = squeeze(mean(REV_COMMON_TOPO,1));
REV_COMMON_TOPO = REV_COMMON_TOPO(1:63, );

%average the voltages across electrodes
REV_COMMON_TOPO = mean(REV_COMMON_TOPO,2);

% change the size of the matrix 
REV_COMMON_TOPO = REV_COMMON_TOPO'; 




% ODDBALL RARE 
OB_RARE_TOPO = GrandAverageEEG(:,2,:,:);
OB_RARE_TOPO = squeeze(mean(OB_RARE_TOPO,1));
OB_RARE_TOPO = OB_RARE_TOPO(1:63,  );

%average the voltages across channels
OB_RARE_TOPO = mean(OB_RARE_TOPO,2);

% change the size of the matrix 
OB_RARE_TOPO = OB_RARE_TOPO'; 
 



% REVERSAL RARE
REV_RARE_TOPO = GrandAverageEEG(:,4,:,:); 
REV_RARE_TOPO = squeeze(mean(REV_RARE_TOPO,1));
REV_RARE_TOPO = REV_RARE_TOPO(1:63, );

%average the voltages across channels
REV_RARE_TOPO = mean(REV_RARE_TOPO,2);

% change the size of the matrix
REV_RARE_TOPO = REV_RARE_TOPO'; 


%% Figures for condition differences (oddball vs. reversal)

% differnece between oddball common and oddball rare
ob_diff_topo = OB_RARE_TOPO - OB_COMMON_TOPO; 
% differnece between reversal common and reversal rare
rev_diff_topo = REV_RARE_TOPO - REV_COMMON_TOPO; % p= chp switch ; g = chp steady

figure;
subplot(1,2,1)
elec = EEG.chanlocs(1:63); 
topoplot(ob_diff_topo, elec);
caxis([-3, 3]) 
title('OB rare - OB common')
subplot(1,2,2)
topoplot(rev_diff_topo,elec);
caxis([-3, 3])
title('REV rare - REV common')
sgtitle('Condition differences')

%% Figures for trial type differences (common vs. rare)

% rev common - odd common
common_diff_topo = REV_COMMON_TOPO - OB_COMMON_TOPO;
% rev rare - odd rare
rare_diff_topo = REV_RARE_TOPO - OB_RARE_TOPO;

figure;
subplot(1,2,1)
elec = EEG.chanlocs(1:63); 
topoplot(common_diff_topo, elec);
caxis([-1.5, 1.5])
title('REV common - OB common')
subplot(1,2,2)
topoplot(rare_diff_topo,elec);
caxis([-1.5, 1.5])
title('REV rare - OB rare')
sgtitle('Trial type differences')

%% Figures for condition & trial types (4 individual plots)

figure;
subplot(2,2,1)
elec = EEG.chanlocs(1:63); 
topoplot(OB_COMMON_TOPO, elec); %oddball common
cbar('vert', 0,[-1, 1]*max(abs(OB_COMMON_TOPO)));
title('Oddball Common')
subplot(2,2,2)
topoplot(OB_RARE_TOPO, elec); %oddball rare
cbar('vert', 0,[-1, 1]*max(abs(OB_RARE_TOPO)));
title('Oddball Rare')
subplot(2,2,3)
topoplot(REV_COMMON_TOPO, elec); %reversal common
cbar('vert', 0,[-1, 1]*max(abs(REV_COMMON_TOPO)));
title('Reversal Common')
subplot(2,2,4)
topoplot(REV_RARE_TOPO, elec); %reversal rare
cbar('vert', 0,[-1, 1]*max(abs(REV_RARE_TOPO)));
title('Reversal Rare')
sgtitle('300-400ms')


%Exploratory analyses ideas: 
% Option1: Look at different ERPs, 2nd ERP analyses (different time when another stimuli is shown,
% e.g. the cue [Brain reacts differently to cue after a surprising stimuli
% has been shown]. e.g. choice [something insteresting happens when you
% make a choice in the brain). This analyses doesn't have to be fully
% hypotheses driven. Timewindow and all have to be reported ofc. 
%If we do that: make the time window that it doesn't touch any other
%process/stimulus
%option 2: Compare ERP and behavioral data. Ask Alexa for behavioral data.
%Correlate the data. [If you are surprised in the outcome, you should
%change your behavior]. [I'm in favor of this option, as be can reason this
%since Matt Nassar (2019) and colleagues did this too.] 
%We need 2. script to show Alexa that we did it correctly. 
%Option 3: any other thing we want to do. 

%For our introduction: What we do is.... [maybe a replication? maybe
%testing a simplifyed paradigma to the canon task?]