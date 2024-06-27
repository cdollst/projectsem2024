%% About
% This script was created by Dr. Alexa Ruel for educational purposes in the context of the Project Seminar Course at the University of Hamburg and should not be used without direct authorization from Dr. Ruel
% Last updated on: April 24, 2024
% Email Dr. Ruel at alexa.ruel@uni-hambrug.de with any questions, concerns or to request permission to use this script outside the course.

%Before running this script, all epochs are in a mess, all artifacts are removed, we only have chunks of data according to the triggers, we also have labels (i.e., oddball, etc.), we do this to get the
%average per condition, per trial to create the grand average of that one
%trial type per condition, we want four categories or lines

% We have 4 conditions (common, oddball, rare, reversal-learning). We get 4
% averages (1 for each condition), then we average those for all
% participants 

%%We sampled [collected data] at 500 Hz. That was then transfered to
%%1000Hz. 
%Rereferencing: FP2 was the reference electrode. 20  (P8) is wrong, she wrongly
%said that before. Rereferecing to the average of the mastoids TP9 and TP10

%Run the grand average 3 times, save it, run the stats on each grand average, each time

%% 1. Create Grand Average;

cd '/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar' % where data is saved (folder with last preprocessing step) 

%Initializing loop to create grand averages, the loop will run 3 times
for x = 1:3
    x= string(x); 
    disp(x)

subjects = [1, 2, 4, 5, 6]; % all the subject numbers have to be entered here, you put all subjects here at once, not just one at a time, you can't move to this script until you finish preprocessing all the data of all the subjects beforehand

GrandAverageEEG = nan(length(subjects), 4, 61, 750); %Grandaverage 4D: subjects, conditions, channels, time; you create the matrix and then fill it in the next loops; nan means 'not a number', the size of the matrix has 4 dimensions 1., how many subjects you have inserted up above (i.e., insert number after length(), 2., conditions (4 different averages/lines), 3., channels or electrodes (63 we don't include the reference electrode (the 64th electrode in this)), 4., the length of the epoch, or the time window/duration of the epoch (note that we might have to change this number if it gives us an error)
%the only number we change up above is the number of subjects, everything
%else should stay the same!
%nan = not a number

%Loop through each subject and load the preprocessed EEG dataset for that
%subject
for i = 1 : length(subjects) %it will run through it a certain number of times depending on the number of subjects you input
    EEG = pop_loadset([strcat(num2str(subjects(i)), '_07_ICAdone.set')]); % change _07_ICAdone.set to the name of the file of the last preprocessing 

 %%
    %Initialize an empty cell array to store epoch names
    EpochNames = {}; %create an empty list called epochnames, matlab prefers that you initialize the variable, and then later on fill it

    %within each subject, then go through each epoch, it classifies each
    %epoch and relabels it for each participant, originally one tag was a
    %condition and one tag was a surprise
    %this loops through each epoch and labels it

    %Relabel the epochs based on condition and if they were surprising or
    %not
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

    %This is a Check! This takes all the epochs of the conditions and
    %prints them. There I should see the devide into 80 and 20% of the
    %oddball conditions suprise and common

    %You can go through this and look at all epochs with the various name we just relabled, it takes the percentage of these, and prints them; this prints in the command window as it's doing this, as it's doing it, you know that these trials (rare trials) are roughly 20%, so the common should be roughly 80% - allows you to see if you labeled your epochs properly and see if you made a mistake somewhere beforehand; sometimes people didn't complete the trial as they answered too fast or too slow, so it's not exact 
    %you have to create your own checks when you code to make sure it does
    %what you intended it to do

    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'oddball_common')))/length(EEG.epoch)) ' % stimuli of type oddball_common'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'oddball_rare')))/length(EEG.epoch)) ' % stimuli of type oddball_rare'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'reversal_common')))/length(EEG.epoch)) ' % stimuli of type reversal_common'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'reversal_rare')))/length(EEG.epoch)) ' % stimuli of type reversal_rare'])

    %List the trial labels out
    epochtrans2 = {'oddball_common' 'oddball_rare' 'reversal_common' 'reversal_rare'};

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

%%%From here: Define & Equalize trials 

%Create variables with lists with the ephocs from the respective
%condition, nummerically in a list. create code that say take random sample
%out of these lists with a number that is equal to the number in the rare
%list. save it. hint: function (find) has to be used within EpochNames to
%find which epochs condition correspond to which label. Also use randSample
%to randomly sample. 

%Find indices of conditions within "EpochNames"
OBCOM = find(strcmp(EpochNames,"oddball_common"));
RVCOM = find(strcmp(EpochNames, "reversal_common"));
OBRARE = find(strcmp(EpochNames, "oddball_rare"));
RVRARE = find(strcmp(EpochNames,"reversal_rare"));

%Randomly sample epochs to equalize the number of trials across conditions 
IndOBCOM = randsample(OBCOM, length(OBRARE));
IndOBRARE = randsample(OBRARE, length(OBRARE));
IndRVCOM = randsample(RVCOM, length(RVRARE));
IndRVRARE = randsample(RVRARE, length(RVRARE));
Indicies = [IndOBCOM, IndOBRARE, IndRVCOM, IndRVRARE];

%Update EEG data and epochs to nly include the selected indices
EEG.data = EEG.data(:, :, Indicies);
EEG.epoch = EEG.epoch(:, Indicies);
EpochNames = {};

%Fill grand average with means per condition, iterating through each epoch
%type, counts the number of trials, and adds the mean data for that condition to `GrandAverageEEG`.
epochtrans2 = {'oddball_common' 'oddball_rare' 'reversal_common' 'reversal_rare'};
    for nc = 1 : length(epochtrans2)
        n_trials(i,nc) = sum(sum(strcmpi(EpochNames,epochtrans2{nc}))); 

        % save the current subject's data to GrandAverageEEG
        GrandAverageEEG(i,nc,:,:) = mean(EEG.data(:,:,strcmpi(EpochNames,epochtrans2{nc})),3);
    end

%Save data by creating a save path using 'x' and save the GrandAverageEEG matrix to a mat file    
path = strcat('/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar', x, '.mat'); 
save(path, "GrandAverageEEG")

end 
end 

%Number of epochs from the rare trials should be >30. Also, number of rare
%and common trials should also not differ too much in theory. Thats why we
%reduce the number of the trials in commumn 1 and 3 (the commons) to the
%number of epochs from the 2nd and 4th collumn (rare trials) - we randomly
%choose the number of rare trials from the common trials. AFterwards, we
%statistically check if the chosen ephocs are representative for the whole
%many. 

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

% The plot created in the following should be saved and labeled :)
%you want to see your four lines altogether

close all; %if you have any figures open on your screen it will close them all
hfig = figure;
hold on;

%the following code chooses the electrode of interest (For example Fz)
% I can find the corresponding number of the electrode in the eeg data information

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

%if using more than one electrode for an ROI, write electrodes as a list and then uncomment the last line of the following 3 "create" sections below because you need to squeeze and mean for each electrode:
%elec = [2, 23, 12] %this is only an example of the electrodes you'd want to insert;
%it then creates an average of all electrodes, she recommends we do this
%once with all electrodes at once to see what it looks like

% all electrodes averaged together, then uncomment the second comment for all create sections below:
%elec = [1 : 63];

% Create electrode(s) by time point for ODDBALL_COMMON: 1 x num time points
OB_COMMON = GrandAverageEEG(:,1,elec,:); %the colon : means all values or levels in that dimension i.e, here that is "all subjects", '1' corresponds to "oddball common" as it's ordered in the step/script above, 'elec' is the number of the electrode you want, predetermined above, at all time points (the second colon); your matrix at this point is all subjects, one condition, 1 electrode, and all time points, but you want to take the mean of the subjects first (see next line)
%OB_COMMON = GrandAverageEEG(:,1,:,:);%uncomment this line if you do an ROI for all electrodes
OB_COMMON = squeeze(mean(OB_COMMON,1)); %averaged across electrodes = 1 x
%time points (squeeze: make the 4 d matrix 2 d by deleting all the columns that only say 1)

% Create electrode(s) by time point for ODDBALL_RARE: 1 x num time points
OB_RARE = GrandAverageEEG(:,2,elec,:);
%OB_RARE = GrandAverageEEG(:,2,:,:); %uncomment this if you do an ROI for all electrodes
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

%at the end of this, each corresponds to the data you need! you have taken something 4D and made it 2D

%just plot the four lines now (which you just created), the times, oddball common, time, oddball
%rare, time, etc., it needs to be told what the x range is
plot (EEG.times, OB_COMMON,'b', EEG.times, OB_RARE, '--b', EEG.times, REV_COMMON, 'r', EEG.times, REV_RARE, '--r') %--b is blue color with a dashed line, --r is red color with a dashed line; EEG.times is x-axis
title(['EEG at ' EEG.chanlocs(elec).labels]) %label associated with the channel of the electrode
set(gca, 'YDir') %this sets the direction, positive is plotted up
legend %gives us a legend that corresponds to the code above
xlabel('time'); ylabel('uV') %x axis is labeled time, y axis is labeled microvolts
xlim([-200 1000]); %if you run this whole thing you should get a plot! xlim limits the plot, only tell matlab to plot according ot your epoch window otherwise the plot will be empty as you only have data in this window anyways

%do this 4 times for each of the conditions if you want 4 plots. colors: b
%blue, --b dashed blue, r red, --r dashed red; YDir - have the y axis
%normally and not reversely plotted

% The plot that opens is modifiable, for example through the edit Reiter.
% Add a legend and all if its not there yet. Adjust the scales of the
% y-axis so that it is the same for all plots of the different electrodes. 
%SAVE it :) as a matab figure and a jng. -> can still edit it and put it in
%a ppt. 

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

%timewindow300_400 = 401.451 %figure out the appropriate time windows according to matlab before running this

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

% difference between oddball common and oddball rare
ob_diff_topo = OB_RARE_TOPO - OB_COMMON_TOPO; 
% difference between reversal common and reversal rare
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