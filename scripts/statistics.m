%% Extract Values from the GrandAverageEEG for your statistical analysis
% Assuming GrandAverageEEG is a 4D double array with dimensions: subjects, conditions, channels, time

cd '/Users/colleen/Desktop/sose-24/Project/eeg-data-class-project-seminar'

%%
%Create association
EEG = pop_loadset('2_07_ICAdone.set');

%%
% Define the time window you are interested in
time_window = find(EEG.times >= 300 & EEG.times <= 400);  % specific time window you want to extract. recall that this is not in ms, but in timepoints in your EEG struct

% Define the specific electrode you are interested in
%elec = 2; %Fz
%elec = 23; %Cz
elec = 12; %Pz 

%%
% Preallocate matrix for storing data
num_subjects = 6; % Update this according to your actual number of subjects
num_conditions = 4; % As per the design: 'oddball_common', 'oddball_rare', 'reversal_common', 'reversal_rare'

% Initialize an empty array to store extracted data for each condition
extracted_data = nan(num_subjects, num_conditions);

for subj = 1:num_subjects
    for cond = 1:num_conditions
        % Extract the mean value in the specified time window for each condition
        condition_data = squeeze(mean(GrandAverageEEG(subj, cond, elec, time_window), 4));
        extracted_data(subj, cond) = mean(condition_data);
    end
end
%%
% Reshape the extracted data appropriately for ANOVA
% Each column in extracted_data represents a condition, and each row represents a subject
[~, table, stats] = anova1(extracted_data);

% Display the ANOVA table in the MATLAB Command Window
disp(table);

%%
% Perform paired t-tests for each pair of conditions
for i = 1:num_conditions
    for j = i+1:num_conditions
        [h, p, ci, stats] = ttest(extracted_data(:,i), extracted_data(:,j));
        fprintf('Condition %d vs Condition %d: t(%d) = %.3f, p = %.4f\n', ...
                i, j, stats.df, stats.tstat, p);
    end
end
%%
%elec = [43, 12, 51]; % ROI

% Get the indices of the time window in the GrandAverageEEG array
 
% Preallocate cell array to store the data
% We will store data in the format: Subject, Condition, Time, Value
data_to_save = {};

% Iterate over subjects
for subject = 1 % 1:6 % you can also keep the original subject IDs, by using the method used in the other scripts.
    % Iterate over conditions
    for condition = 1:4 %change depending on whatever participants you're looking at (i.e., 1:6)
        % Extract the data for the current subject, condition, and the specific channel at the specified time window
        
        values = squeeze(mean(GrandAverageEEG(subject, condition, elec, time_window),3)); %3 is the dimension across which you're squeezing and meaning,doing this, removes the electrode, so it's not per-electrode, but the average
        
        % Add the data to the cell array
        for t = 1:length(time_window)
            data_to_save = [data_to_save; {subject, condition, time_window(t), values(t)}];
        end
    end
end

% Convert the cell array to a table, has to be called a table for matlab to
% export it to csv
data_table = cell2table(data_to_save, 'VariableNames', {'Subject', 'Condition', 'Time_point', 'Value'}); %variable names at the top of the table are subject, condition, time point, and value, because you're averaging across electrodes, same as grandaverage

% Save the table as a CSV file
writetable(data_table, 'extracted_data_300-400.csv'); %writetable function saves the table you just created

disp('Data has been extracted and saved to extracted_data.csv');

%if you open the csv now, everything is separated by commas into one sheet,
%you can import it into R now, you should have the columns: subject, condition,
%time_point, and value (for that time point what is the value in
%micro-volts?)