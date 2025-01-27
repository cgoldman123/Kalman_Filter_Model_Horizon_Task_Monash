function [all_data, subj_mapping] = merge_horizon(dir_name)        
    % This function reads data files from a specified directory, filters for valid datasets 
    % (with more than 40 trials), assigns a unique subject ID to each dataset, and combines 
    % all the valid datasets into a single array while creating a mapping of subjects.    

    directory = dir(dir_name);
    subj_mapping = struct();
    all_data = {};
    n = 0;
    for i = 1:length(directory)
        file_name = directory(i).name;

        % Skip directories '.' and '..'
        if strcmp(file_name, '.') || strcmp(file_name, '..')
            continue;
        end

        data = parse_horizon(fullfile(dir_name, file_name));  
        % Check if the file contains valid data
        if (size(data, 1) > 40)
            n = n + 1;
            % Append to subj_mapping table with index n and subjectID from data
            subj_mapping(n).n = n;
            subj_mapping(n).id = data.subjectID(1, :);
            % Add subjectID to the all_data
            all_data{n} = data;
            all_data{n}.subjectID = repmat(n, size(all_data{n}, 1), 1);
        end
    end
    
    all_data = vertcat(all_data{:});    
end
