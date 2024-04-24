%% About
% This script was created by Dr. Alexa Ruel for educational purposes in the context of the Project Seminar Course at the University of Hamburg and should not be used without direct authorization from Dr. Ruel
% Last updated on: April 24, 2024
% Email Dr. Ruel at alexa.ruel@uni-hambrug.de with any questions, concerns or to request permission to use this script outside the course.

%% 1. Create Grand Average;

cd ''

subjects = [];


GrandAverageEEG = nan(length(subjects), 4, 63, ); %Grandaverage 4D: subjects, conditions, channels, time 


for i = 1 : length(subjects)
    EEG = pop_loadset([strcat(num2str(subjects(i)), '_07_ICAdone.set')]);  

 %%
    EpochNames = {}; 

    
    for c = 1 : length(EEG.epoch)
        if EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "steady" 
            EpochNames(c) = {'oddball_steady'}; 
        elseif EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "switch"
             EpochNames(c) = {'oddball_switch'};
        elseif EEG.epoch(c).condition == "changepoint" && EEG.epoch(c).surprise == "steady"
             EpochNames(c) = {'changepoint_steady'};
        elseif EEG.epoch(c).condition == "changepoint" && EEG.epoch(c).surprise == "switch"
             EpochNames(c) = {'changepoint_switch'};
        end
    end

    %This is a Check! 
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'oddball_steady')))/length(EEG.epoch)) ' % stimuli of type oddball_steady'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'oddball_switch')))/length(EEG.epoch)) ' % stimuli of type oddball_switch'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'changepoint_steady')))/length(EEG.epoch)) ' % stimuli of type changepoint_steady'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'changepoint_switch')))/length(EEG.epoch)) ' % stimuli of type changepoint_switch'])

    epochtrans2 = {'oddball_steady' 'oddball_switch' 'changepoint_steady' 'changepoint_switch'};

   
    for nc = 1 : length(epochtrans2)
        n_trials(i,nc) = sum(sum(strcmpi(EpochNames,epochtrans2{nc}))); 

        % save the current subject's data to GrandAverageEEG
        GrandAverageEEG(i,nc,:,:) = mean(EEG.data(:,:,strcmpi(EpochNames,epochtrans2{nc})),3);
    end


end 

%% 2. Plot Grand Average - with both conditions, and trial types shown
close all;
hfig = figure;
hold on;

%elec = 2; %Fz
%elec = 23; %Cz
%elec = 12; %Pz

% if using more than one electrode... 


% Create electrode(s) by time point for ODDBALL_COMMON: 1 x num time points
OB_COMMON = GrandAverageEEG(:,1,elec,:); 
OB_COMMON = squeeze(mean(OB_COMMON,1)); % electrode(s) X time points 
%OB_COMMON = squeeze(mean(OB_COMMON,1)); %averaged across electrodes = 1 x time points 

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
OB_COMMON_TOPO = OB_COMMON_TOPO(1:62, ); % selects only the time range we are interested in for the topography (window of analysis)

%average the voltages across the channels
OB_COMMON_TOPO = mean(OB_COMMON_TOPO,2);

% change the size of the matrix
OB_COMMON_TOPO = OB_COMMON_TOPO';




% REVERSAL COMMON
REV_COMMON_TOPO = GrandAverageEEG(:,3,:,:);
REV_COMMON_TOPO = squeeze(mean(REV_COMMON_TOPO,1));
REV_COMMON_TOPO = REV_COMMON_TOPO(1:62, );

%average the voltages across electrodes
REV_COMMON_TOPO = mean(REV_COMMON_TOPO,2);

% change the size of the matrix 
REV_COMMON_TOPO = REV_COMMON_TOPO'; 




% ODDBALL RARE 
OB_RARE_TOPO = GrandAverageEEG(:,2,:,:);
OB_RARE_TOPO = squeeze(mean(OB_RARE_TOPO,1));
OB_RARE_TOPO = OB_RARE_TOPO(1:62,  );

%average the voltages across channels
OB_RARE_TOPO = mean(OB_RARE_TOPO,2);

% change the size of the matrix 
OB_RARE_TOPO = OB_RARE_TOPO'; 
 



% REVERSAL RARE
REV_RARE_TOPO = GrandAverageEEG(:,4,:,:); 
REV_RARE_TOPO = squeeze(mean(REV_RARE_TOPO,1));
REV_RARE_TOPO = REV_RARE_TOPO(1:62, );

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
elec = EEG.chanlocs(1:62); 
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
elec = EEG.chanlocs(1:62); 
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
elec = EEG.chanlocs(1:62); 
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
sgtitle('500-600ms')
