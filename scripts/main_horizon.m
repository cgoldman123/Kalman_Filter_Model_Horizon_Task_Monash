%% Clear workspace
clear all

dbstop if error

% Determine if running code on pc or cluster
if ispc
    root = 'L:/';
elseif ismac
    root = '/Volumes/labs/';
elseif isunix 
    root = '/media/labs/';
end

% Add path for SPM fitting functions -- will have to download SPM12 if not
% downloaded already https://www.fil.ion.ucl.ac.uk/spm/software/spm12/
% Adjust these variables based on the location of your download.
addpath([root '/rsmith/all-studies/util/spm12/']);
addpath([root '/rsmith/all-studies/util/spm12/toolbox/DEM/']);

%% Read In and Process Data
% Folder containing raw behavioral files
dir_name = '../data/';
% Process behavioral files
[big_table, subj_mapping] = merge_horizon(dir_name);
% Folder to store processed behavioral files
processed_dir = '../processed_data/';
% Get timestamp
timestamp = datestr(datetime('now'), 'mm_dd_yy_THH-MM-SS');
outpath_beh = sprintf([processed_dir 'all_subjects_data_%s.csv'], timestamp);
writetable(big_table, outpath_beh);

%% Perform model fit
% Reads in the above 'outpath_beh' file and fits on this file
fits = fit_extended_model_VB(outpath_beh); % choose fit_extended_model() or fit_extended_model_VB
fits = struct2table(fits);
fits.id = {subj_mapping.id}';
outpath_fits = sprintf(['../fits/horizon_model_%s.csv'], timestamp);
writetable(fits, outpath_fits);

