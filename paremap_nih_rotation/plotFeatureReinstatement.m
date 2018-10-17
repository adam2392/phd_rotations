close all
clc
clear all

subj = 'NIH034';
sessNum = [0, 1, 2];
%% LOAD EVENTS STRUCT AND SET DIRECTORIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------ STEP 1: Load events and set behavioral directories                   ---------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eegRootDirWork = '/Users/liaj/Documents/MATLAB/paremap';     % work
eegRootDirHome = '/Users/adam2392/Documents/MATLAB/Johns Hopkins/NINDS_Rotation';  % home
eegRootDirJhu = '/home/adamli/paremap';

% Determine which directory we're working with automatically
if     length(dir(eegRootDirWork))>0, eegRootDir = eegRootDirWork;
elseif length(dir(eegRootDirHome))>0, eegRootDir = eegRootDirHome;
elseif length(dir(eegRootDirJhu))>0, eegRootDir = eegRootDirJhu;
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

% for i=1:length(events)
%     events(i).mstime = events(i).matchOnTime - events(i).mstime;% - events(i).responseTime;
% end

mean([events.responseTime])
plot([events.mstime])

%%- Section for Pulling reinstatement matrices already produced and just
%%make different plots
ANALYSIS_TYPE = {'within_blocks', 'across_blocks'};
EVENT_SYNC = {'probeon', 'vocalization', 'matchword'};

subj = 'NIH034';
ANALYSIS = ANALYSIS_TYPE{1};
SYNC = EVENT_SYNC{2};

% file dir for all the saved mat files
fileDir = strcat('./Figures/', subj, '/reinstatement_mat/', ANALYSIS, '_', SYNC, '/');

% load in an example data directory to get session names and block number
dataDir = strcat('./condensed_data_', subj);
dataDir = fullfile(dataDir, 'morlet_spec');
sessions = dir(dataDir);
sessions = {sessions(3:end).name};
if strcmp(subj, 'NIH039')
    sessions = sessions([1,2,4]);
elseif strcmp(subj, 'NIH034')
    sessions = sessions([3, 4]);
end
blocks = dir(fullfile(dataDir, sessions{1}));
blocks = {blocks(3:end).name};

% set which blocks to analyze
if strcmp(ANALYSIS, 'across_blocks')
    lenBlocks = length(blocks)-1;
else
    lenBlocks = length(blocks);
end

sessions

avgeReinstatementMat = [];
%- LOOP THROUGH SESSIONS
for iSesh=1:length(sessions),
    
    avgeSameSessionReinstatement = [];
    avgeDiffSessionReinstatement = [];
    %%- LOOP THROUGH BLOCKS
    for iBlock=1:lenBlocks,
        if strcmp(ANALYSIS, 'across_blocks')
            sessionBlockName = strcat(sessions{iSesh}, '-', blocks{iBlock}, 'vs', blocks{iBlock+1});
        else
            sessionBlockName = strcat(sessions{iSesh}, '-', blocks{iBlock});
        end
        fileToLoad = fullfile(fileDir, sessionBlockName);
        data = load(fileToLoad);
        
        %%- LOAD IN THE DATA SAVED 
        eventSame = data.eventSame;
        eventDiff = data.eventDiff;
        featureSame = data.featureSame;
        featureDiff = data.featureDiff;
        if strcmp(ANALYSIS, 'across_blocks')
            eventProbe = data.eventProbe;
            eventReverse = data.eventReverse;
            eventTarget = data.eventTarget;
            featureReverse = data.featureReverse;
            featureTarget = data.featureTarget;
            featureProbe = data.featureProbe;
        end
       
        %%- Section to make averaged responses
        if isempty(avgeSameSessionReinstatement)
            avgeSameSessionReinstatement = eventSame; %permute(eventSame, [3, 1, 2]);
            avgeDiffSessionReinstatement = eventDiff;
        else
            avgeSameSessionReinstatement = cat(1, avgeSameSessionReinstatement, eventSame);
            avgeDiffSessionReinstatement = cat(1, avgeDiffSessionReinstatement, eventDiff);
        end
        
        size(featureDiff)
        size(featureSame)
        
        % rand sample down the different word pair feature mat -> match
        % size
%         randIndices = randsample(size(eventDiff,1), size(eventSame,1));
%         eventDiff = eventDiff(randIndices,:,:);
        
%         featureIndices = 55*7:72*7;
        featureIndices = 54*7:72*7;
        featureSame = featureSame(featureIndices,:,:);
        featureDiff = featureDiff(featureIndices,:,:);
        
        size(featureDiff)
        size(featureSame)
        
        if strcmp(SYNC, 'vocalization')
            ticks = [6:10:56];
            labels = [-3:1:2];
            timeZero = 36;
        elseif strcmp(SYNC, 'matchword')
            ticks = [6:10:56];
            labels = [-4:1:1];
            timeZero = 46;
        elseif strcmp(SYNC, 'probeon')
            ticks = [6:10:56];
            labels = [0:1:5];
            timeZero = 6;
        end
        
        % set linethickness
        LT = 1.5;
        
        %%- Plotting
        figure
        subplot(311)
        imagesc(squeeze(mean(featureSame(:, :, :),1)));
        title(['Same Pairs Cosine Similarity'])
        hold on
        xlabel('Time (seconds)');
        ylabel('Time (seconds)');
        ax = gca;
        axis square
        ax.YTick = ticks;
        ax.YTickLabel = labels;
        ax.XTick = ticks;
        ax.XTickLabel = labels;
        colormap('jet');
        set(gca,'tickdir','out','YDir','normal');
        set(gca, 'box', 'off');
        colorbar();
        clim = get(gca, 'clim');
        hold on
        plot(get(gca, 'xlim'), [timeZero timeZero], 'k', 'LineWidth', LT)
        plot([timeZero timeZero], get(gca, 'ylim'), 'k', 'LineWidth', LT)
       
        subplot(312);
        imagesc(squeeze(mean(eventDiff(:, :, :),1)));
        title(['Different Word Pairs Cosine Similarity for Block ', num2str(iBlock-1)])
        hold on
        xlabel('Time (seconds)');
        ylabel('Time (seconds)');
        ax = gca;
        axis square
        ax.YTick = ticks;
        ax.YTickLabel = labels;
        ax.XTick = ticks;
        ax.XTickLabel = labels;
        colormap('jet');
        set(gca,'tickdir','out','YDir','normal');
        set(gca, 'box', 'off');
        colorbar();
        set(gca, 'clim', clim);
        hold on
        plot(get(gca, 'xlim'), [timeZero timeZero], 'k', 'LineWidth', LT)
        plot([timeZero timeZero], get(gca, 'ylim'), 'k', 'LineWidth', LT)
        
        subplot(313);
        imagesc(squeeze(mean(eventSame(:, :, :),1)) - squeeze(mean(eventDiff(:, :, :),1)));
        title(['Same-Different Word Pairs Cosine Similarity for Block ', num2str(iBlock-1)])
        hold on
        xlabel('Time (seconds)');
        ylabel('Time (seconds)');
        ax = gca;
        axis square
        ax.YTick = ticks;
        ax.YTickLabel = labels;
        ax.XTick = ticks;
        ax.XTickLabel = labels;
        colormap('jet');
        set(gca,'tickdir','out','YDir','normal');
        set(gca, 'box', 'off');
        colorbar();
        hold on
        plot(get(gca, 'xlim'), [timeZero timeZero], 'k', 'LineWidth', LT)
        plot([timeZero timeZero], get(gca, 'ylim'), 'k', 'LineWidth', LT)
        
        %%- Save Image
%         print(figureFile, '-dpng', '-r0')
%         savefig(figureFile)
        
        pause(0.1);
    end % loop through blocks
end % loop through sessions