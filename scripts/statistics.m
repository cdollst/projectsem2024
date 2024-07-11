%% Extract Values from the GrandAverageEEG for your statistical analysis
% Assuming GrandAverageEEG is a 4D double array with dimensions: subjects, conditions, channels, time

cd '/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar'

% Load the EEG data
load('GrandAverageEEG1.mat'); % Update the file path and name as needed

% Load the EEG set (assuming this is necessary for context or timing information)
EEG = pop_loadset('2_07_ICAdone.set');

%%
% Define electrode and time window for analysis
electrode_of_interest = 12; % Pz; adjust as needed
time_window = find(EEG.times >= 300 & EEG.times <= 400);

% Number of subjects and conditions
num_subjects = 6; 
num_conditions = 4;

% Preallocate a large enough cell array to store the data
data_to_save = cell(num_subjects * num_conditions * length(time_window), 4);

% Initialize a counter for the cell array index
counter = 1;

% Iterate over subjects
for subject = 1:num_subjects
    % Iterate over conditions
    for condition = 1:num_conditions
        % Extract the data for the current subject, condition, and the specific channel at the specified time window
        values = squeeze(mean(GrandAverageEEG(subject, condition, electrode_of_interest, time_window), 3));
        
        % Add the data to the cell array
        for t = 1:length(time_window)
            data_to_save{counter, 1} = subject;
            data_to_save{counter, 2} = condition;
            data_to_save{counter, 3} = EEG.times(time_window(t));
            data_to_save{counter, 4} = values(t);
            counter = counter + 1;
        end
    end
end

% Convert the cell array to a table
data_table = cell2table(data_to_save, 'VariableNames', {'Subject', 'Condition', 'Time_point', 'Value'});

% Save the table as a CSV file
writetable(data_table, 'extracted_data_300-400.csv');

disp('Data has been extracted and saved to extracted_data_300-400.csv');

%The ID of the subject. This ranges from 1 to the total number of subjects (e.g., 1 to 6).

%Condition: The ID of the experimental condition. This ranges from 1 to the total number of conditions (e.g., 1 to 4).

%Time_point: The specific time point (in milliseconds) within the 300-400 ms time window for which the value is recorded.

%Value: The averaged EEG signal amplitude at the Pz electrode for the given subject, condition, and time point.