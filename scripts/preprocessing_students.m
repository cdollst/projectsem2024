eeglab

%% About
% This script was created by Dr. Alexa Ruel for educational purposes in the context of the Project Seminar Course at the University of Hamburg and should not be used without direct authorization from Dr. Ruel
% Last updated on: April 22, 2024
% Email Dr. Ruel at alexa.ruel@uni-hambrug.de with any questions, concerns or to request permission to use this script outside the course.

%% 1. Re-sample and filter the raw data 
% First, you need to down sample and filter your data. Since this is the first step, you will be importing the raw data files.

subjects = [1, 2, 3, 4, 5, 6];

%Paths match the dataset location
raw_data_path = '/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar'
save_data_path = '/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar'

for id = subjects
    id_str = num2str(id); %Convert the subject ID to string 
    disp(id_str)

    %Construct the original file name
    orig_file_name = [id_str, '.vhdr']
    disp(orig_file_name)

    %Load EEG data
    EEG = pop_loadbv(raw_data_path, orig_file_name, [],1:63);
    
    %Resample the data to 500 Hz (technically the raw data is already
    %sampled at 500 Hz so we're really not resampling, but we're leaving
    %this in for holistic purposes
    EEG = pop_resample(EEG, 500);

    %Filter the data with a bandpass filter between 0.5 and 30 Hz
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.5,'hicutoff',30,'plotfreqz',1);

    %Construct the filename for the processed data
    new_setname= strcat(id_str, '_filtered_resampled.set');

    %Save the processed EEG data
    EEG = pop_saveset(EEG, 'filename', char(new_setname), 'filepath', char(save_data_path));

end

%% 2. Re-reference the data the to average of the mastoids
% Remember that data is always recorded with ONE reference electrode. 
% In our case, this is the LEFT MASTOID. To remove this bias,we need to re-reference the data to the average of the left (TP9) and right mastoids (TP10).

%Define the subject IDs
subjects = [1, 2, 3, 4, 5, 6];

%Paths
filtered_data_path = '/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar'
save_data_path = '/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar'

for id = subjects
    id_str = num2str(id); % convert the variable id to string
    
    %Construct the file name for loading
    filtered_file_name = [id_str, '_filtered_resampled.set'];
    disp(['Loading file: ', filtered_file_name])

    %Load the filtered and resampled EEG data
    EEG = pop_loadset('filename', filtered_file_name, 'filepath', filtered_data_path);

    %Re-reference the data to the average of the mastoids: channels 20
    %(left), the right is already the reference used in EEGlab so we don't
    %need to input it
    EEG = pop_reref(EEG, [10, 21],'keepref','off'); %fill the brackets with the electrodes that correspond to TP9 and TP10

    %Construct the filename for saving the re-referenced data
    reref_file_name = [id_str, '_02_reref.set'];
    disp(['Saving file as: ', reref_file_name])

    %Save the re-referenced EEG data
    EEG = pop_saveset(EEG, 'filename', char(reref_file_name), 'filepath', char(save_data_path));

    %Confirm save
    if exist(fullfile(save_data_path, reref_file_name), 'file')
        disp(['File saved successfully for subject ID: ', id_str])
    else
        disp(['Error: File not saved for subject ID: ', id_str])
    end
end

%% 3. Visual Inspection to Check & Deal with bad channels & interpolate channels & reject bad data
% There are many ways to check for and reject bad channels.
% Check the EEGLAB tutorial manual for the different methods.
% Recommended: visual inspection per participant, and interpolate bad channels. Keep note below of which channels and how many per subjectyou interpolate so you can decide if you should reject the participant overall.

% Check S. Luck book for recommendations regarding when to exclude a subject
% Scrolling through your data will also help you see how good or bad your data are, and help guide you in the next steps!

% comment everything!!!!
% example of a interpolated channels comment: 2001 - TP10

%Participant 1: No bad channels interpolated, but overall messy data across all the channels

%Participant 2: TP7, TP8 - they pick up on noise but they don't anything

%Participant 3: P8 (flat)

%Participant 4: None interpolated

%Participant 5: None interpolated

%Participant 6: None interpolated

%Note on naming conventions for the group: first visually inspected data,
%this visually inspected/rejected dataset is named
%participant_03_visuallyinspec (e.g.,2_03_visuallyinspec for participant 2)
%then the channels are interpolated and this dataset should be named (after
%all necessary channels are interpolated, participant_03_inter, e.g.,
%2_03_inter for participant 2

%% 4. Epoching
% This is where you decide on how and around which trigger to chunk up your data for later averaging.
% Remember that this should not impede on other stimulus presentation, and if it overlaps with responses, you will need to correct for this.

% Define the subject IDs to process
subjects = [1, 2, 3, 4, 5, 6];

% Define file paths
raw_data_path = '/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar'; 
save_data_path = '/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar';

% Define epoch length in seconds
epoch_length = [-0.5 1];

% Define the event types (triggers) for epoching
event_types = {'S 40', 'S 41', 'S 42', 'S 43', 'S 44', 'S 45', 'S 46', 'S 47', 'S 90', 'S 91', 'S 92', 'S 93', 'S 94', 'S 95', 'S 96', 'S 97'}; %are 94-97 correct to add? If so, add them in the code below too...

% Loop through each subject
for id = subjects
    % Convert subject ID to string
    id_str = num2str(id); 
    disp(['Processing subject: ', id_str])
    
    % Load the re-referenced EEG data
    filename = sprintf('%d_03_inter.set', id);
    EEG = pop_loadset('filename', filename, 'filepath', raw_data_path);
    
    % Epoch the data around the defined triggers
    EEG = pop_epoch(EEG, event_types, epoch_length, 'epochinfo', 'yes');
    
    % Remove baseline
    EEG = pop_rmbase(EEG, [-500 0]);  % Baseline correction in milliseconds
    
    % Add tags/names for the epochs based on the events
    for i = 1:length(EEG.epoch)
        % Find the locking event (stimulus)
        I0 = find([EEG.epoch(i).eventlatency{:}] == 0);
        event_type = EEG.epoch(i).eventtype{I0};
        
        % Assign properties based on the event type
        switch event_type
            case 'S 40'
                EEG.epoch(i).condition = 'oddball';
                EEG.epoch(i).trialtype = 'assoc1';
                EEG.epoch(i).stimulus = 'house1';
                EEG.epoch(i).surprise = 'common';

            case 'S 42'
                EEG.epoch(i).condition = 'oddball';
                EEG.epoch(i).trialtype = 'assoc1';
                EEG.epoch(i).stimulus = 'house2';
                EEG.epoch(i).surprise = 'common';

            case 'S 41'
                EEG.epoch(i).condition = 'oddball';
                EEG.epoch(i).trialtype = 'assoc2';
                EEG.epoch(i).stimulus = 'house1';
                EEG.epoch(i).surprise = 'rare';

            case 'S 43'
                EEG.epoch(i).condition = 'oddball';
                EEG.epoch(i).trialtype = 'assoc2';
                EEG.epoch(i).stimulus = 'house2';
                EEG.epoch(i).surprise = 'rare';

            case 'S 44'
                EEG.epoch(i).condition = 'reversal';
                EEG.epoch(i).trialtype = 'assoc1';
                EEG.epoch(i).stimulus = 'house1';
                EEG.epoch(i).surprise = 'common';

            case 'S 46'
                EEG.epoch(i).condition = 'reversal';
                EEG.epoch(i).trialtype = 'assoc1';
                EEG.epoch(i).stimulus = 'house2';
                EEG.epoch(i).surprise = 'common';

            case 'S 45'
                EEG.epoch(i).condition = 'reversal';
                EEG.epoch(i).trialtype = 'assoc2';
                EEG.epoch(i).stimulus = 'house1';
                EEG.epoch(i).surprise = 'common';

            case 'S 47'
                EEG.epoch(i).condition = 'reversal';
                EEG.epoch(i).trialtype = 'assoc2';
                EEG.epoch(i).stimulus = 'house2';
                EEG.epoch(i).surprise = 'common';

            case 'S 90'
                EEG.epoch(i).condition = 'reversal';
                EEG.epoch(i).trialtype = 'assoc1';
                EEG.epoch(i).stimulus = 'house1';
                EEG.epoch(i).surprise = 'rare';

            case 'S 92'
                EEG.epoch(i).condition = 'reversal';
                EEG.epoch(i).trialtype = 'assoc1';
                EEG.epoch(i).stimulus = 'house2';
                EEG.epoch(i).surprise = 'rare';

            case 'S 91'
                EEG.epoch(i).condition = 'reversal';
                EEG.epoch(i).trialtype = 'assoc2';
                EEG.epoch(i).stimulus = 'house1';
                EEG.epoch(i).surprise = 'rare';

            case 'S 93'
                EEG.epoch(i).condition = 'reversal';
                EEG.epoch(i).trialtype = 'assoc2';
                EEG.epoch(i).stimulus = 'house2';
                EEG.epoch(i).surprise = 'rare';
                
            case 'S 94'
                EEG.epoch(i).condition = 'oddball';
                EEG.epoch(i).trialtype = 'assoc2';
                EEG.epoch(i).stimulus = 'house1';
                EEG.epoch(i).surprise = 'common';

            case 'S 95'
                EEG.epoch(i).condition = 'oddball';
                EEG.epoch(i).trialtype = 'assoc2';
                EEG.epoch(i).stimulus = 'house1';
                EEG.epoch(i).surprise = 'rare';

            case 'S 96'
                EEG.epoch(i).condition = 'oddball';
                EEG.epoch(i).trialtype = 'assoc2';
                EEG.epoch(i).stimulus = 'house2';
                EEG.epoch(i).surprise = 'common';

            case 'S 97'
                EEG.epoch(i).condition = 'oddball';
                EEG.epoch(i).trialtype = 'assoc2';
                EEG.epoch(i).stimulus = 'house2';
                EEG.epoch(i).surprise = 'rare';
            
        end
    end

    % Update the setname in EEGlab structure
    EEG.setname = strcat(id_str, '_04_epoched');

    % Save the epoched data
    save_filename = strcat(id_str, '_04_epoched.set');
    EEG = pop_saveset(EEG, 'filename', save_filename, 'filepath', save_data_path);

    % Confirm save
    if exist(fullfile(save_data_path, save_filename), 'file')
        disp(['Epoched file saved successfully for subject ID: ', id_str])
    else
        disp(['Error: Epoched file not saved for subject ID: ', id_str])
    end
end

%Participant 1: 458 epochs generated, 8 Trials removed, 18 unreferenced
%Events removed = 429 epochs, 560 events, 61 channels per frame, 750 frames

%Participant 2: 480 epochs generated, 9 trials removed, 26 unreferenced
%events removed = 471 epochs, 624 events, 61 channels per frame, 750 frames
%per epoch

%Participant 3: 501 epochs generated, 13 trials removed, 35 unreferenced
%events removed = 488 epochs, 638 events, 63 channels per frame, 750 frames
%per epoch

%Participant 4: 382 epochs generated, 8 trials removed, 21 unreferenced
%events removed > 374 epochs generated, 495 events, 61 channels per frame, 750 frames per epoch

%Participant 5: 485 epochs generated, 3 trials removed, 8 unreferenced events removed > 481 epochs left, 642 events, 61 channels per frame, 750 frames per epoch > after epoch rejection: 477 epochs

%Participant 6: 484 epochs generated, 7 trials removed, 15 unreferenced
%events removed = 477 epochs, 623 events, 61 channels per frame, 750 frames
%per epoch

%% Manually reject "bad epochs"
% Once again, go through the epochs, and via visual inspection, delete those that are "bad".
% Keep note below of how many epochs you reject to decide if any subject should be rejected based on this.

%Participant 1: %Rejected for the triggers: S30 - 1, S40 - 5, S34 - 1, S36- 1, S42 - 4, S44 - 2, S46 - 2, S47- 1, S81 - 1, S84 - 2, S96- 1, S93- 1, S94 - 2,
%S96 - 4

%Participant 2: no rejected epochs

%Participant 3: S30/S40, S42, S42, S45, S96, S84/S96, S46, S94, S96, S45, S34/S44 - 11 trials removed

%Participant 4: no rejected epochs

%Participant 5: 4 rejected epochs that looked excessively jiggly or had a really obvious short spike somewhere

%Participant 6: S42, S42, S43, S45, S46, S91, S93, S94, S96, S96 - 10 trials removed

%Named the dataset with rejected epochs as "participant_04_epochfin"

%% 5.  Run the ICA (Independent Component Analysis)
% Run the independent component analysis.
% NOTE: this will take some time. Make sure you can let your computer run the ICA uninterupted (including its own sleep/shut down mode)
% This step simply runs the ICAs, without having you select components or reject them yet.

subjects = [1, 2, 3, 4, 5, 6]; %put all the datasets together, step by step, run the ICA on all of the datasets at one time

for id = subjects %only one subject here
    id_str = num2str(id); %Convert subject ID to string
    disp(['Preprocessing subject ID: ', id_str])

    %Load the final epoched file from the previous step
    filename = strcat(id_str, '_04_epochfin.set');
    EEG = pop_loadset('filename', filename, 'filepath', preprocessed_data_path);

    %Run ICA
    EEG = pop_runica(EEG, 'runica', 'extended', 0); %all the functions that it's unmixing in the ICA occur with this pop_runica function

    %Update the setname and save the ICA results
    EEG.setname= strcat(id_str, '_05_ICArun');
    filename_save = strcat(id_str,'_05_ICArun.set'); %we do it three steps so that if we later decide to select other components, we don't have to run the whole entire processes again!
    EEG = pop_saveset( EEG, 'filename', filename_save, 'filepath', save_data_path); %it will tell you what matrix is loading, it decomposes into different frames, searches for a learning rate where it starts at a certain starting point, then it searches on how to best fit that dataset, learning rate changes on every iteration, it starts somewhere, finds that, then as it goes through it adjusts, and finds the right value for that dataset, then plugs in specific values for the various components. Once it finishes it rescales things, then the >> appear when it's done.

    disp(['ICA ran and saved for subject ID: ', id_str])
end

%% 6. Manual component selection
% This script will load each file saved from the last step, and ask you to manually select all bad components which will be rejected in the next step.
% Once you click ok, and then press any key with your cursor in the console, it will load the next particioant and so on until you are done.

subjects = [1, 2, 3, 4, 5, 6];

for id = subjects %Loop through your subjects
    id_str = num2str(id); 
    disp(['Selecting components for subject ID: ', id_str])

    %Load the ICA results
    EEG = pop_loadset('filename', strcat(id_str, '_05_ICArun.set'), 'filepath', save_data_path); %load dataset from last step

    %Open component selection GUI
    pop_selectcomps(EEG, 1:40); %any component after 40 (depends on researcher/data) it's so rare that that component happened in your data, you don't need all of them
    pause %Wait for manual selection of components

    %Save the components selected for rejection
    VP_INFO.icaweights = EEG.icaweights; %a measurement of how much of each component was in your data
    VP_INFO.icasphere = EEG.icasphere; %information you need in order to plot the components
    %VP_INFO; %plots the different components
    %pause %stops and waits until you do your job for each participant, and click on the components you don't like based on the map,(click reject then go to the next copmonent); once you're done with this step, it still won't continue after you press ok, so you need to click into your command window
    VP_INFO.ICA_Remove = find(EEG.reject.gcompreject==1);

    save(fullfile(save_data_path,[id_str '_ICA_info.mat']), 'VP_INFO')%Save component info
    
    %Save the dataset with components marked for rejection
    EEG.setname= strcat(id_str, '_06_ICAselected');
    filename_save = strcat(id_str, '_06_ICAselected.set');
    EEG = pop_saveset( EEG, 'filename', filename_save, 'filepath', save_data_path);

    disp(['Components selected and saved for subject ID: ', id_str])
end

%% 7.  Remove components marked in previous step
% this step simply removes all the components you marked in the previous step.
% The benefit of doing this in many steps is being able to go back and see which components you rejected and modify if you need to!

subjects = [1, 2, 3, 4, 5, 6];

for id = subjects
    id_str = num2str(id); 
    disp(['Removing components for subject ID: ', id_str])
    
    %Load the dataset with marked components
    EEG = pop_loadset('filename', strcat(id_str, '_06_ICAselected.set'), 'filepath', save_data_path);

    %Display components being removed
    disp(['Removing ' num2str(sum(EEG.reject.gcompreject)) ' ICs.']) %displays the number of components that you want rejected
    
    %Remove the marked components
    EEG = pop_subcomp( EEG, find(EEG.reject.gcompreject==1), 0); %removes or subtracts the components you want it to subtract

    %Update the setname and save the cleaned dataset
    EEG.setname= strcat(id_str, '_07_ICAdone');
    filename_save = strcat(id_str,'_07_ICAdone.set');
    EEG = pop_saveset(EEG, 'filename', filename_save, 'filepath', save_data_path);

    disp(['Components removed and dataset saved for subject ID: ', id_str])
end

%Participant 1: Removed 24 components

%Participant 2: Removed 16 components

%Participant 3: Removed 17 components

%Participant 4: Removed 25 components

%Participant 5: Removed 32 components

%Participant 6: Removed 19 components

% If you made it this far, good job! You are now ready to create a grand average plot to visualise your ERP. :) 