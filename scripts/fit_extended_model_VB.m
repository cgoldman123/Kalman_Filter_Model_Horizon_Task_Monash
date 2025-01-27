function [fits, model_output] = fit_extended_model_VB(formatted_file)
    % set working directory and change path
    fundir      = pwd;
    addpath(fundir);
    cd(fundir);

    % load data
    sub = load_horizon_data(formatted_file);

    % prep data structure 
    L = unique(sub(1).gameLength); % length of games (5 choices or 10)
    NS = length(sub);   % number of subjects
    T = 4;              % number of forced choices
    
    NUM_GAMES = max(vertcat(sub.game), [], 'all');

    a  = zeros(NS, NUM_GAMES, T); % forced choices
    c5 = nan(NS,   NUM_GAMES); % free choices
    r  = zeros(NS, NUM_GAMES, T); % forced choice rewards
    UC = nan(NS,   NUM_GAMES); % equal (1) or unequal (2) info
    GL = nan(NS,   NUM_GAMES); % game length

    for sn = 1:length(sub)

        % choices on forced trials
        dum = sub(sn).a(:,1:4);
        a(sn,1:size(dum,1),:) = dum;

        % choices on free trial
        % note a slight hacky feel here - a is 1 or 2, c5 is 0 or 1.
        dum = sub(sn).a(:,5) == 2;
        L(sn) = length(dum);
        c5(sn,1:size(dum,1)) = dum;

        % rewards
        dum = sub(sn).r(:,1:4);
        r(sn,1:size(dum,1),:) = dum;

        % game length
        dum = sub(sn).gameLength;
        GL(sn,1:size(dum,1)) = dum;

        G(sn) = length(dum);

        % uncertainty condition 
        dum = abs(sub(sn).uc - 2) + 1;
        UC(sn, 1:size(dum,1)) = dum;

        % difference in information; right informativeness
        dum = sub(sn).uc - 2;
        dI(sn, 1:size(dum,1)) = -dum;


    end

    GL(GL==5) = 1;
    GL(GL==10) = 2;

    C1 = (GL-1)*2+UC; % h1_equal = 1; h1_unequal = 2; h6_equal = 3; h6_unequal = 4
    nC1 = 4;


    % meaning of C1 (SMT FIXED)
    % GL UC C1
    %  1  1  1 - horizon 1, [2 2]
    %  1  2  2 - horizon 1, [1 3]
    %  2  1  3 - horizon 6, [2 2]
    %  2  2  4 - horizon 6, [1 3]



    datastruct = struct(...
        'C1', C1, 'nC1', nC1, ...
        'NS', NS, 'G',  G,  'T',   T, ...
        'dI', dI, 'a',  a,  'c5',  c5, 'r', r);

    

    if ispc
        root = 'L:/';
    elseif ismac
        root = '/Volumes/labs/';
    elseif isunix 
        root = '/media/labs/';
    end
    
    fprintf( 'Running Newton Function to fit\n' );

    % initialize parameters
    MDP.datastruct = datastruct;
    MDP.params.info_bonus_h1 = 0; % information bonus in H1 games
    MDP.params.info_bonus_h6 = 0; % information bonus in H6 games
    MDP.params.dec_noise_h1_22 = 1; % decision noise in H1 games with equal information
    MDP.params.dec_noise_h1_13 = 1; % decision noise in H1 games with unequal information
    MDP.params.dec_noise_h6_22 = 1; % decision noise in H6 games with equal information
    MDP.params.dec_noise_h6_13 = 1; % decision noise in H6 games with unequal information
    MDP.params.spatial_bias_h1_22 = 0; % spatial bias in H1 games with equal information
    MDP.params.spatial_bias_h1_13 = 0; % spatial bias in H1 games with unequal information
    MDP.params.spatial_bias_h6_22 = 0; % spatial bias in H6 games with equal information
    MDP.params.spatial_bias_h6_13 = 0; % spatial bias in H6 games with unequal information
    MDP.params.alpha_inf = .5; 
    MDP.params.alpha_start = .5; 
    MDP.field = fieldnames(MDP.params);

    for k = 1:NS
        MDP.datastruct = datastruct;
        MDP.datastruct.C1 = datastruct.C1(k,:);
        MDP.datastruct.G = datastruct.G(k);
        MDP.datastruct.dI = datastruct.dI(k,:);
        MDP.datastruct.forced_choices = squeeze(datastruct.a(k,:,:))';
        MDP.datastruct.c5 = datastruct.c5(k,:);
        MDP.datastruct.r = squeeze(datastruct.r(k,:,:))';

        % Fit the model 
        DCM = horizon_inversion(MDP);
        
        field = DCM.field;
        fits(k).id = k;
        fits(k).num_games_played = MDP.datastruct.G;
        % Re-transform parameters back to native space
        for i = 1:length(field)
            if ismember(field{i},{'alpha_start', 'alpha_inf'})
                fits(k).(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));
                params.(field{i}) = fits(k).(field{i});
            elseif ismember(field{i}, {'dec_noise_h1_22', 'dec_noise_h1_13', 'dec_noise_h6_22', 'dec_noise_h6_13' })
                fits(k).(field{i}) = exp(DCM.Ep.(field{i}));
                params.(field{i}) = fits(k).(field{i});
            elseif ismember(field{i},{'info_bonus_h1', 'info_bonus_h6', 'spatial_bias_h1_22', 'spatial_bias_h1_13', 'spatial_bias_h6_22', 'spatial_bias_h6_13'})
                fits(k).(field{i}) = DCM.Ep.(field{i});
                params.(field{i}) = fits(k).(field{i});
            else
                disp(field{i});
                error("Param not propertly transformed");
            end
        end
        % Using the posterior estimates of fitted parameters, run the model
        % to find the average probability assigned to participant choices
        % (average action prob) and the percentage of choices that the
        % model correctly predicted (i.e., assigned a probability greater
        % than .5)
        model_output = model_KFcond_v2_SMT_CMG(params,MDP.datastruct.c5, MDP.datastruct.r,MDP.datastruct);
        fits(k).directed_exploration = fits(k).info_bonus_h6 - fits(k).info_bonus_h1;
        fits(k).random_exploration = fits(k).dec_noise_h6_22 - fits(k).dec_noise_h1_22;
        fits(k).average_action_prob = mean(model_output.action_probs(~isnan(model_output.action_probs)), 'all');
        fits(k).model_acc = sum(model_output.action_probs(~isnan(model_output.action_probs)) > 0.5) / numel(model_output.action_probs(~isnan(model_output.action_probs)));
        
        
    end
   

    
    
 end