eeglab

%% About
% This script was created by Dr. Alexa Ruel for educational purposes in the context of the Project Seminar Course at the University of Hamburg and should not be used without direct authorization from Dr. Ruel
% Last updated on: April 24, 2024
% Email Dr. Ruel at alexa.ruel@uni-hambrug.de with any questions, concerns or to request permission to use this script outside the course.
%before this script, all epochs are in a mess, all artifacts are removed, we only have chunks of data according to the triggers, we also have labels (i.e., oddball, etc.), we do this to get the
%average per condition, per trial to create the grand average of that one
%trial type per condition, we want four categories or lines
%% 1. Create Grand Average;

cd ''%working directory path, direct the pathname to the last preprocessing step data folder, post ICA

subjects = [];%i.e., 2001, 2005 etc., you put all subjects here at once, not just one at a time, you can't move to this script until you finish preprocessing all the data of all the subjects beforehand


GrandAverageEEG = nan(length(subjects), 4, 63, 750); %Grandaverage 4D: subjects, conditions, channels, time; you create the matrix and then fill it in the next loops; nan means 'not a number', the size of the matrix has 4 dimensions 1., how many subjects you have inserted up above (i.e., insert number after length(), 2., conditions (4 different averages/lines), 3., channels or electrodes (63 we don't include the reference electrode (the 64th electrode in this)), 4., the length of the epoch, or the time window/duration of the epoch (note that we might have to change this number if it gives us an error)
%the only number we change up above is the number of subjects, everything
%else should stay the same!
%nan = not a number

for i = 1 : length(subjects) %it will run through it a certain number of times depending on the number of subjects you input
    EEG = pop_loadset([strcat(num2str(subjects(i)), '_07_ICAdone.set')]); %(_07_ICAdone.set) insert here whatever your last dataset from the preprocessing step was i.e., load the most recent dataset  

 %%
    EpochNames = {}; %create an empty list called epochnames, matlab prefers that you initialize the variable, and then later on fill it

    %within each subject, then go through each epoch, it classifies each
    %epoch and relabels it for each participant, originally one tag was a
    %condition and one tag was a surprise
    %this loops through each epoch and labels it
    for c = 1 : length(EEG.epoch)
        if EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "common" % steady = common
            EpochNames(c) = {'oddball_common'}; %instead of having two labels per epoch, as above, combine them to have one label for the epoch
        elseif EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "rare"
             EpochNames(c) = {'oddball_rare'};
        elseif EEG.epoch(c).condition == "reversal" && EEG.epoch(c).surprise == "common"
             EpochNames(c) = {'reversal_common'};
        elseif EEG.epoch(c).condition == "reversal" && EEG.epoch(c).surprise == "rare"
             EpochNames(c) = {'reversal_rare'};
        end
    end

    %This is a Check! you can go through this and look at all epochs with the various name we just relabled, it takes the percentage of these, and prints them; this prints in the command window as it's doing this, as it's doing it, you know that these trials (rare trials) are roughly 20%, so the common should be roughly 80% - allows you to see if you labeled your epochs properly and see if you made a mistake somewhere beforehand; sometimes people didn't complete the trial as they answered too fast or too slow, so it's not exact 
    %you have to create your own checks when you code to make sure it does
    %what you intended it to do
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'oddball_common')))/length(EEG.epoch)) ' % stimuli of type oddball_common']) %by design you should have roughly 80 percent or 40
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'oddball_rare')))/length(EEG.epoch)) ' % stimuli of type oddball_rare']) %by design you should have roughly 20 percent or 10
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'reversal_common')))/length(EEG.epoch)) ' % stimuli of type reversal_common']) %by design you should have roughly 80 percent or 40
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'reversal_rare')))/length(EEG.epoch)) ' % stimuli of type reversal_rare']) %by design you should have roughly 20 percent or 10

    %list the labels out
    epochtrans2 = {'oddball_common' 'oddball_rare' 'reversal_common' 'reversal_rare'}; % go through each item in the list, and count how many trials correspond to that label, in the previous step you have a rough percentage

%find all the epochs with each of those tags, assign them into a variable,
%choose into the oddball common and reversal common, randomly in that
%number of trials, a number that is equal to the trials in the condition
%then subset data with indices, recheck epoch and label, then check again
%that all numbers are equal, they should no longer be 90 or 10

   %count the number of trials (this is still in the loop for one person,
   %you want to know, for each person, how many trials of each type did
   %they complete, and are you going to include in the analysis? if when
   %you check the numbers of trials, you have less than 30 trials in the OB
   %rare or reversal learning rare, it's not enough to use that person's
   %data - different types of components will need different types of
   %trials
    for nc = 1 : length(epochtrans2) %per person, you want to know out of all of the trials of the epoch that wasn't deleted, how many correspond to the current conditions, there should be more common epochs than rare epochs
        n_trials(i,nc) = sum(sum(strcmpi(EpochNames,epochtrans2{nc}))); 

        % save the current subject's data to GrandAverageEEG for subject
        % one, this fills in the matrix where each line goes subject by
        % subject
        GrandAverageEEG(i,nc,:,:) = mean(EEG.data(:,:,strcmpi(EpochNames,epochtrans2{nc})),3);
    end


end 

%if you do this step, and the numbers aren't what you expect, it's a way to
%check that everything is labeled correctly
%the output (grandaverage matrix in the workspace, is 4-D and so large,
%that it cannot be displayed; subjects, conditions (4 different lines we're
%looking at), electrodes, and time (MATLAB time)

%after running the above block, the output in the command window will say:
%the different number or percentages of trials for each label, it won't be
%exact as we excluded some trials (look for a ballpark idea to make sure
%your trials were tagged correctly); nothing prints but you can go to the
%grand average in the workspace to look at the values of the 4D matrix;
%these numbers then reflect the signal at each electrode per subject, per
%timepoint!

%% 2. Plot Grand Average - with both conditions, and trial types shown
%you want to see your four lines altogether
close all; %if you have any figures open on your screen it will close them all
hfig = figure;
hold on;

%effect at P300 occurs at the parietal region, this drives the search, we
%predict that the P300 is a parietal P300; some people plot one electrode
%(Pz), but you can also choose a region of interest, ROI such as P1, PZ, &
%P3. This guided by past research, but also what you see in your own research
%data. To see this, look at what the other electrodes look like, which is
%why you should run this again, again, and again. Do one, save it, do
%another one, save it. This is the only way if you're going to understand
%if your data is clean and what you're looking at.

%uncomment these to activate them, the electrode numbers and corresponding Fz/Cz
%etc., is in our EEG structure from our workspace from the previous
%preprocessing step (EEG chanloc) or EEG channel locations, the number to
%the left of it, is the electrode number, give MATLAB the number not the
%label. You have to deal with the number here. Previous literature has told
%us what the effect should be and you want to see what the data looks like

% first define an electrode, or the number associated with each electrode,
% you'll know which number to use as it's in the EEG structure in the
% workspace where you can really see it through "chanlocs" or channel
% locations, the number you need to give matlab are the ones in the field;
% Pz corresponds to the number 12

%elec = 2; %Fz
%elec = 23; %Cz
%elec = 12; %Pz

%save the plots and then label them, so that you know what it actually is!
%GA = subjects, conditions, electrodes, time -> you want the average
%subject, maintain conditions, select electrodes and average ROI, and
%maintain your time; the condition maintainence has to be done 4 different
%times (once for each condition)

% if using more than one electrode for an ROI, write electrodes as a list and then uncomment the last line of the following 3 "create" sections below because you need to squeeze and mean for each electrode:
%elec = [2, 23, 12] %this is only an example of the electrodes you'd want to insert;
%it then creates an average of all electrodes, she recommends we do this
%once with all electrodes at once to see what it looks like

% all electrodes averaged together, then uncomment the second comment for all create sections below:
%elec = [1 : 63];

% Create electrode(s) by time point for ODDBALL_COMMON: 1 x num time points
OB_COMMON = GrandAverageEEG(:,1,elec,:); %the colon : means all values or levels in that dimension i.e, here that is "all subjects", '1' corresponds to "oddball common" as it's ordered in the step/script above, 'elec' is the number of the electrode you want, predetermined above, at all time points (the second colon); your matrix at this point is all subjects, one condition, 1 electrode, and all time points, but you want to take the mean of the subjects first (see next line)
%OB_COMMON = GrandAverageEEG(:,1,:,:);%uncomment this if you do an ROI for
%all electrodes
OB_COMMON = squeeze(mean(OB_COMMON,1)); % electrode(s) X time points; squeeze = remove the dimensions that are just 1, it doesn't matter anymore, you end up with a matrix at this point that is just the electrodes by time point (you squeeze out (remove) the single condition you have; if you only fed in one electrode, you don't need another line, but if you wanted to do an ROI, you have to mean and squeeze again; once we've obtained the mean of dimension 1, matlab sees one dimension for the electrode, subjects, electrode, and it sees all time points, by squeezing, you're left with all data points according to time and no more overflow of ones
%OB_COMMON = squeeze(mean(OB_COMMON,1)); %averaged across electrodes = 1 x time points 
%the above line is commented out because you only have to run this line if
%you're running an ROI across condition... (? unsure if I heard correctly)

% Create electrode(s) by time point for ODDBALL_RARE: 1 x num time points
OB_RARE = GrandAverageEEG(:,2,elec,:);
%OB_RARE = GrandAverageEEG(:,2,:,:); %uncomment this if you do an ROI for
%all electrodes
OB_RARE = squeeze(mean(OB_RARE,1));
%OB_RARE = squeeze(mean(OB_RARE,1));

% Create electrode(s) by time point for REVERSAL_COMMON: 1 x num time points
REV_COMMON = GrandAverageEEG(:,3,elec,:);
%REV_COMMON = GrandAverageEEG(:,3,:,:);
REV_COMMON = squeeze(mean(REV_COMMON,1));
%REV_COMMON = squeeze(mean(REV_COMMON,1));

% Create electrode(s) by time point for REVERSAL_RARE: 1 x num time points
REV_RARE = GrandAverageEEG(:,4,elec,:); 
%REV_RARE = GrandAverageEEG(:,4,:,:); 
REV_RARE = squeeze(mean(REV_RARE,1));
%REV_RARE = squeeze(mean(REV_RARE,1));

%at the end of this, each corresponds to the data you need! you have taken
%something 4D and made it 2D

%just plot the four lines now (which you just created), the times, oddball common, time, oddball
%rare, time, etc., it needs to be told what the x range is.
plot (EEG.times, OB_COMMON,'b', EEG.times, OB_RARE, '--b', EEG.times, REV_COMMON, 'r', EEG.times, REV_RARE, '--r') %--b is blue color with a dashed line, --r is red color with a dashed line; EEG.times is x-axis
title(['EEG at ' EEG.chanlocs(elec).labels]) %label associated with the channel of the electrode
set(gca, 'YDir') %this sets the direction, positive is plotted up
legend %gives us a legend that corresponds to the code above
xlabel('time'); ylabel('uV') %x axis is labeled time, y axis is labeled microvolts
xlim([-200 1000]); %if you run this whole thing you should get a plot! xlim limits the plot, only tell matlab to plot according ot your epoch window otherwise the plot will be empty as you only have data in this window anyways


%% Difference Value Plots.
%Makes a difference wave, the range is smaller
ob_diff = OB_RARE - OB_COMMON ; %create a difference between the two
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
legend %blue line is average of oddball common oddball rare, red line is reversal common reversal rare
xlabel('time'); ylabel('EEG')


% trial type difference values
plot (EEG.times, common_diff, EEG.times, rare_diff)
title(['EEG at ' EEG.chanlocs(elec).labels])
set(gca, 'YDir')
legend
xlabel('time'); ylabel('EEG')


%% 3. Topographies

%organize the data in a way so that you can then use the function to plot
%unlike above, we're not plotting a grand average across time, but an average according
%to a heatmap. There are four parts to it, the same thing is done, four
%times, for each of those conditions

%timewindow300_400 = 401.451 %figure out the appropriate time windows
%according to matlab before running this

% ODDBALL COMMON
OB_COMMON_TOPO = GrandAverageEEG(:,1,:,:); %take the grandaverage, all subjects, then select the condition, all electrodes, and all time points
OB_COMMON_TOPO = squeeze(mean(OB_COMMON_TOPO,1)); % squeezes the 4D matrix into a channels by timepoints matrix. So squeezes across all subjects (means) or dimension 1; if you want 300 to 400 across all electrodes averaged across subjects, and all electrodes, you mean across subjects and squeeze
OB_COMMON_TOPO = OB_COMMON_TOPO(:, timewindow300_400); % selects only the time range we are interested in for the topography (window of analysis); write out all electrodes for the whole topography, the other two numbers are the timepoints according to matlab in ms - you know what to put here based off of your EEG structure in the workspace -> go to times -> the lower boundary is on the far left most upward cell, the upper boundary is the last, most upward cell listed NOTE: the timepoints you have to refer to are the numbers in the title of the column in matlab... (e.g., timepoint 300 corresponds to 401 in the title of the column, so you would enter that here) 

%average the voltages across the channels
OB_COMMON_TOPO = mean(OB_COMMON_TOPO,2); %topo = topographies

% change the size of the matrix
OB_COMMON_TOPO = OB_COMMON_TOPO';

%squeezes across participants, just time window you're interested in,
%averaged across channels, and then transposes the matrix; we select all
%electrodes in the time window we want for the topography

% REVERSAL COMMON
REV_COMMON_TOPO = GrandAverageEEG(:,3,:,:);
REV_COMMON_TOPO = squeeze(mean(REV_COMMON_TOPO,1));
REV_COMMON_TOPO = REV_COMMON_TOPO(:, timewindow300_400);

%average the voltages across electrodes
REV_COMMON_TOPO = mean(REV_COMMON_TOPO,2);

% change the size of the matrix 
REV_COMMON_TOPO = REV_COMMON_TOPO'; 




% ODDBALL RARE 
OB_RARE_TOPO = GrandAverageEEG(:,2,:,:);
OB_RARE_TOPO = squeeze(mean(OB_RARE_TOPO,1));
OB_RARE_TOPO = OB_RARE_TOPO(:, timewindow300_400);

%average the voltages across channels
OB_RARE_TOPO = mean(OB_RARE_TOPO,2);

% change the size of the matrix 
OB_RARE_TOPO = OB_RARE_TOPO'; 
 



% REVERSAL RARE
REV_RARE_TOPO = GrandAverageEEG(:,4,:,:); 
REV_RARE_TOPO = squeeze(mean(REV_RARE_TOPO,1));
REV_RARE_TOPO = REV_RARE_TOPO(:, timewindow300_400);

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
caxis([-1.5, 1.5]) %caxis, color axis, you can put values in here and it will restrict the range, if this is commented out, matlab will put a range it thinks is good but it will be wrong scales, so you can't compare them, if you want to compare them, uncomment them, you can tell matlab what access you want and put them on the same scale you can look at them and see the average activity as the difference value for common trials and rare trials
title('REV common - OB common')
subplot(1,2,2)
topoplot(rare_diff_topo,elec);
caxis([-1.5, 1.5])
title('REV rare - OB rare')
sgtitle('Trial type differences')

%% Figures for condition & trial types (4 individual plots)

figure;
subplot(2,2,1)
elec = EEG.chanlocs(1:63); %tell matlab which electrodes to use to plot because with the variable we created above, from the topo structure, it's just numbers, so use the EEG channel location structure, so that matlab knows what data goes where
topoplot(OB_COMMON_TOPO, elec); %oddball common; topoplot needs an x and y value like a regular plot, needs the data, and the electrodes to create the topography plot
cbar('vert', 0,[-1, 1]*max(abs(OB_COMMON_TOPO))); %cbar is the color bar, you want a different one per plot
title('Oddball Common') %gives a title to each of the subplots
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
sgtitle('500-600ms') %this is the big title, change the ms here according to what you're plotting e.g., 300-400ms

%topographies are plotted in conjunction with your grand averages!