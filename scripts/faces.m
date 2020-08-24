function faces(sub,input_counterbalance_file, run_num)
%% -----------------------------------------------------------------------------
%                           Parameters
% ------------------------------------------------------------------------------

%% A. Psychtoolbox parameters _________________________________________________
global p
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screens                        = Screen('Screens'); % Get the screen numbers
p.ptb.screenNumber             = max(screens); % Draw to the external screen if avaliable
p.ptb.white                    = WhiteIndex(p.ptb.screenNumber); % Define black and white
p.ptb.black                    = BlackIndex(p.ptb.screenNumber);
[p.ptb.window, p.ptb.rect]     = PsychImaging('OpenWindow',p.ptb.screenNumber,p.ptb.black);
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize',p.ptb.window);
p.ptb.ifi                      = Screen('GetFlipInterval',p.ptb.window);
Screen('BlendFunction', p.ptb.window,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('TextFont', p.ptb.window, 'Arial');
Screen('TextSize', p.ptb.window, 18);
[p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);
p.fix.sizePix                  = 40; % size of the arms of our fixation cross
p.fix.lineWidthPix             = 4; % Set the line width for our fixation cross
p.fix.xCoords                  = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                  = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                = [p.fix.xCoords; p.fix.yCoords];

%% B. Directories ______________________________________________________________
task_dir                       = pwd;
main_dir                       = fileparts(task_dir);
taskname                       = 'faces';
dir_video                      = fullfile(main_dir,'stimuli','videos');
counterbalancefile             = fullfile(main_dir,'design', [input_counterbalance_file, '.csv']);
countBalMat                    = readtable(counterbalancefile);
countBalMat                    = countBalMat(countBalMat.RunNumber==run_num,:);
%% D. making output table ________________________________________________________
vnames = {'param_fmriSession', 'param_counterbalanceVer','param_videoFilename',...
    'p1_fixation_onset','p1_fixation_duration',...
    'p2_administer_type','p2_administer_filename','p3_administer_onset',...
    'p3_actual_onset','p3_actual_responseonset','p3_actual_RT'};
T                              = array2table(zeros(size(countBalMat,1),size(vnames,2)));
T.Properties.VariableNames     = vnames;

a                              = split(counterbalancefile,filesep);
version_chunk                  = split(extractAfter(a(end),"ver-"),"_");
T.param_fmriSession(:)=run_num;
T.param_counterbalanceVer(:)   = str2double(version_chunk{1});
T.param_videoFilename          = countBalMat.image_filename;

%% E. Keyboard information _____________________________________________________
KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.right                   = KbName('2');
p.keys.left                    = KbName('1');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');
p.keys.trigger                 = KbName('5%');
p.keys.start                   = KbName('s');
p.keys.end                     = KbName('e');

%% F. fmri Parameters __________________________________________________________
TR                             = 0.46;

%% G. Instructions _____________________________________________________________
order=rem(sub,2)+1;
if order==1
judgements = {'AGE' 'SEX' 'INTENSITY'};
else
judgements = {'INTENSITY'  'SEX'  'AGE'};    
end
instruct_start                 = ['Please indicate the ' judgements{run_num} ' of the face.'];
instruct_end                   = 'This is the end of the experiment. Please wait for the experimenter';

taskname = judgements{run_num};
%% C. Circular rating scale _____________________________________________________
image_filepath                 = fullfile(main_dir,'stimuli','ratingscale');
image_scale_filename           = lower(['task-',taskname,'_scale.jpg']);
image_scale                    = fullfile(image_filepath,image_scale_filename);


%% -----------------------------------------------------------------------------
%                              Start Experiment
% ------------------------------------------------------------------------------

%% ______________________________ Instructions _________________________________
Screen('TextSize',p.ptb.window,36);
DrawFormattedText(p.ptb.window,instruct_start,'center',p.ptb.screenYpixels/2+150,255);
Screen('Flip',p.ptb.window);

%% _______________________ Wait for Trigger to Begin ___________________________
DisableKeysForKbCheck([]);
KbTriggerWait(p.keys.start);
Screen('TextSize',p.ptb.window,28);
DrawFormattedText(p.ptb.window,'Waiting for trigger','center',p.ptb.screenYpixels/2,255);
Screen('Flip',p.ptb.window);
T.param_triggerOnset(:) = KbTriggerWait(p.keys.trigger);
WaitSecs(TR*6);

%% 0. Experimental loop _________________________________________________________
for trl = 1:size(countBalMat,1)

    %% 1. Fixtion Jitter  ____________________________________________________
    jitter1 = countBalMat.ISI(trl)-1;
    Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    fStart1 = GetSecs;
    Screen('Flip', p.ptb.window);
    WaitSecs(jitter1);
    fEnd1 = GetSecs;
    
    T.p1_fixation_onset(trl) = fStart1;
    T.p1_fixation_duration(trl) = fEnd1 - fStart1;
    
    %% 2. face ________________________________________________________________
    video_filename = [countBalMat.image_filename{trl}];
    video_file = fullfile(dir_video, video_filename);
    movie_time = video_play(video_file , p );
    T.p2_administer_onset(trl) = movie_time;
    
    
    %% 3. post evaluation rating ___________________________________________________
    T.p3_actual_onset(trl) = GetSecs;
    [trajectory, RT, buttonPressOnset] = circular_rating_output(1.875,p,image_scale,judgements{run_num});
    rating_Trajectory{trl,2} = trajectory;
    T.p3_actual_responseonset(trl) = buttonPressOnset;
    T.p3_actual_RT(trl) = RT;
    
end

%% ______________________________ Instructions _________________________________
Screen('TextSize',p.ptb.window,36);
DrawFormattedText(p.ptb.window,instruct_end,'center',p.ptb.screenYpixels/2+150,255);
Screen('Flip',p.ptb.window);

%% save parameter ______________________________________________________________
sub_save_dir = fullfile(main_dir, 'data', strcat('sub-', sprintf('%03d', sub)), 'beh' );
if ~exist(sub_save_dir, 'dir')
    mkdir(sub_save_dir)
end

saveFileName = fullfile(sub_save_dir,[strcat('sub-', sprintf('%03d', sub)), ...
    '_task-',taskname,'_beh.csv' ]);
writetable(T,saveFileName);

traject_saveFileName = fullfile(sub_save_dir, [strcat('sub-', sprintf('%03d', sub)), ...
    '_task-',taskname,'_beh_trajectory.mat' ]);
save(traject_saveFileName, 'rating_Trajectory');

psychtoolbox_saveFileName = fullfile(sub_save_dir, [strcat('sub-', sprintf('%03d', sub)),...
    '_task-',taskname,'_psychtoolbox_params.mat' ]);
save(psychtoolbox_saveFileName, 'p');

sca;

%% -----------------------------------------------------------------------------
%                                   Function
%-------------------------------------------------------------------------------
% Function by Xiaochun Han
    function [Tm] = video_play(moviename,p)
        % [p.ptb.window, rect]  = Screen(p.ptb.screenID, 'OpenWindow',p.ptb.bg);
        Tt = 0;
        rate = 1;
        [movie, ~, ~, imgw, imgh] = Screen('OpenMovie', p.ptb.window, moviename);
        Screen('PlayMovie', movie, rate);
        Tm = GetSecs;
        t = 0; dur = 0;
        while 1
            if ((imgw>0) && (imgh>0))
                tex = Screen('GetMovieImage', p.ptb.window, movie, 1);
                t = t + tex;
                if tex < 0
                    break;
                end
                
                if tex == 0
                    WaitSecs('YieldSecs', 0.005);
                    continue;
                end
                Screen('DrawTexture', p.ptb.window, tex);
                Screen('Flip', p.ptb.window);
                Screen('Close', tex);
            end
        end
        Screen('Flip', p.ptb.window);
        Screen('PlayMovie', movie, 0);
        Screen('CloseMovie', movie);
    end

end
