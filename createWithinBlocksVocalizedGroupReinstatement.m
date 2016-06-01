% function createWithinBlocksVocalizedGroupReinstatement(subj)
    close all;
    
    subj = 'NIH034';
    sessNum = [0, 1, 2];
    addpath('./m_reinstatement/');
    
    %% LOAD EVENTS STRUCT AND SET DIRECTORIES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%------------------ STEP 1: Load events and set behavioral directories                   ---------------------------------------%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    eegRootDirJhu = '/home/adamli/paremap';     % work
    eegRootDirWork = '/Users/liaj/Documents/MATLAB/paremap'; 
    eegRootDirHome = '/Users/adam2392/Documents/MATLAB/Johns Hopkins/NINDS_Rotation';  % home


    % Determine which directory we're working with automatically
    if     length(dir(eegRootDirWork))>0, eegRootDir = eegRootDirWork;
    elseif length(dir(eegRootDirJhu))>0, eegRootDir = eegRootDirJhu;
    elseif length(dir(eegRootDirHome))>0, eegRootDir = eegRootDirHome;
    else   error('Neither Work nor Home EEG directories exist! Exiting'); end

    % Either go through all the sessions, or a specific session
    if sessNum == -1 | length(sessNum)>1, % all sessions
        disp('STEP 1: Going through all sessions')
        session = 'Meta Session [all]';
        behDir=fullfileEEG(eegRootDir, subj, '/behavioral/paRemap');
        sessStr = '[all]';
    else                                  % one session
        disp('STEP 1: Going through one session')
        session = sprintf('session_%d',sessNum);
        behDir=fullfileEEG(eegRootDir, subj, '/behavioral/paRemap/', session);
        sessStr = sprintf('[%d]',sessNum);
    end

    subjDir = fullfileEEG(eegRootDir,subj); % directory to subject (e.g. NIH034)
    docsDir = fullfileEEG(subjDir,'docs');  % directory to the docs (electordes.m, tagNames.txt, etc.)
    talDir  = fullfileEEG(subjDir,'tal');
    defaultEEGfile = fullfileEEG('/Volumes/Shares/FRNU/data/eeg/',subj,'/eeg.reref/');  % default event eegfile fields point here... switch to local before loading

    %%-Load in the Events For This Task/Patient/Session
    events = struct([]);                    %%- in functional form this is required so there is no confusion about events the function and events the variable
    load(sprintf('%s/events.mat',behDir));  %%- load the events file
    fprintf('Loaded %d events from %s\n', length(events), behDir);
    %%- GET CORRECT EVENTS ONLY
    % POST MODIFY EVENTS based on fields we want (e.g. is it correct or not)?
    correctIndices = find([events.isCorrect]==1);
    events = events(correctIndices);
    
    TYPE_TRANSF = 'morlet_spec_vocalization';
    disp('WITHIN BLOCKS');
    disp(TYPE_TRANSF);
    
    dataDir = strcat('./condensed_data_', subj);
    dataDir = fullfile(dataDir, TYPE_TRANSF);
    sessions = dir(dataDir);
    sessions = {sessions(3:end).name};
    % sessions = sessions(3:end);

    if strcmp(subj, 'NIH039')
        sessions = sessions([1,2,4]);
    elseif strcmp(subj, 'NIH034')
        sessions = sessions([3, 4]);
    end
    sessions
    blocks = dir(fullfile(dataDir, sessions{1}));
    blocks = {blocks(3:end).name};
    
    allVocalizedPairs = {'CLOCK_JUICE', 'CLOCK_PANTS', 'CLOCK_BRICK', 'CLOCK_GLASS', 'CLOCK_CLOCK',...
                        'BRICK_JUICE', 'BRICK_PANTS', 'BRICK_BRICK', 'BRICK_GLASS', ...
                        'PANTS_JUICE', 'PANTS_PANTS', 'PANTS_GLASS', 'GLASS_JUICE', ...
                        'GLASS_GLASS', 'JUICE_JUICE'};
    length(allVocalizedPairs)
    %% CREATE VOCALIZED WORD GROUPS
    %%- LOOP THROUGH SESSIONS AND BLOCKS
    for iSesh=1:length(sessions),
        for iBlock=1:length(blocks),
            % get word pairs in this session-block
            wordpairs = dir(fullfile(dataDir, sessions{iSesh}, blocks{iBlock}));
            wordpairs = {wordpairs(3:end).name};
            % split each wordpair to get the vocalized word
            vocalizedWords = {};
            for i=1:length(wordpairs)
                string = strsplit(wordpairs{i}, '_');
                vocalizedWords{end+1} = string{2};
            end
            vocalizedWords{:}
            
            allWordCombs = combnk(vocalizedWords, 2)
            allWordIndices = zeros(length(allVocalizedPairs), 1);
            
            % Extract vocalized word pairings
            vocalizedGroups = {};
            for i=1:length(vocalizedWords)
                firstword = strsplit(allWordCombs{i, 1}, '_');
                secondword = strsplit(allWordCombs{i, 2}, '_');
                
            end
            
        end
    end
% end