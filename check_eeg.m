function check_eeg(apassdir,work_dir,eegdata,scoresf)
% Written by ZOU Guangyuan, 2021.09.26
% GUI for manual sleep stage scoring
if nargin == 0
    [pathstr,name,ext] = fileparts(which('check_eeg'));
    apassdir = pathstr;
    work_dir='/disk1/guangyuan/testpipeline2/sub06/cleaned_EEGdata/sub06';
    eegdata = 'sub06_r01_bcgnet.vhdr';
    scoresf='/disk1/guangyuan/testpipeline2/sub06/cleaned_EEGdata/sub06/stage_pred0.txt';
end
scaler = imread([apassdir,'/scaler.jpg']);
%eegdata
global config
config.scoresf = scoresf;
scores = load(scoresf);
cd(work_dir);
mkdir('auto_stage')
copyfile(scoresf,'./auto_stage/');
config.scores = scores+1;
config.scale = 150;
config.epoch_num = 1;
config.stages = {'W','N1','N2','N3','R','UNKNOWN'};
config.channels1 = {'F3','F4','C3','C4','O1','O2','E1','E2','EMG1','EMG2'};
config.channels2 = {'F3','F4','C3','C4','O1','O2','EOG1','EOG2','EMG1','EMG2'};
% -------------------------default settings------------------------------------------------
eeglab nogui
EEG = pop_loadbv(work_dir,eegdata);
EEG = eeg_checkset( EEG );
EEG2 = pop_eegfiltnew(EEG,10,[]);
EEG3 = pop_eegfiltnew(EEG,0.3,[]);
emg1_id = find(strcmp({EEG.chanlocs.labels},'EMG1'));
emg2_id = find(strcmp({EEG.chanlocs.labels},'EMG2'));
EEG3.data([emg1_id,emg2_id],:) = EEG2.data([emg1_id,emg2_id],:);
EEG= EEG3;

try
    for i=1:length(config.channels1)
        chan_id = find(strcmp({EEG.chanlocs.labels},config.channels1{i}));
        data_check(i,:) = EEG.data(chan_id,:);
    end
catch
    try 
        for i=1:length(config.channels2)
            chan_id = find(strcmp({EEG.chanlocs.labels},config.channels2{i}));
            data_check(i,:) = EEG.data(chan_id,:);
        end
    catch
        errordlg({'Channel label error!','Please make sure there are channels',...
            '{F3,F4,C3,C4,O1,O2,E1,E2,EMG1,EMG2} or','{F3,F4,C3,C4,O1,O2,EOG1,EOG2,EMG1,EMG2}'},...
            'error')
    end
end
config.data_check = data_check;
config.srate = EEG.srate;
s.hf = figure('toolbar','figure','MenuBar','none','NumberTitle','off',...
    'Name',eegdata,'Units','normalized','Position',[0.05 0.05 0.95 0.8]);

s.haxes = axes('Parent',s.hf,'Units','normalized','position',[0.05 0.15 0.9 0.8]);
x = 1:30*EEG.srate;
y = -100/config.scale*config.data_check(:,(config.epoch_num-1)*EEG.srate*30+1:config.epoch_num*EEG.srate*30)+ repmat([9:-1:0]',1,EEG.srate*30)*100;

axes(s.haxes);
s.plot = plot(x,y,'b','LineWidth',1.5);
title(config.stages{config.scores(1)},'FontSize',15);
xticks([0:EEG.srate:EEG.srate*30]);
xticklabels([0:1:30]);
ylim([-100,1000]);
yticks([0:100:900]);
yticklabels(fliplr(config.channels2));
xlabel('Time(s)','FontSize',15);
set(gca,'xgrid','on','fontsize',15);
s.scale_axes = axes('Parent',s.hf,'Units','normalized','Position',[0.95 0.15 0.01 0.8/11]);
axes(s.scale_axes);
s.img_scaler = imshow(scaler);

s.scale_text = uicontrol('Parent',s.hf,'Style','text','FontSize',10,'String','Scale:','Units','normalized',...
    'Position',[0.96 0.20 0.02 0.05]);
s.scale_edit = uicontrol('Parent',s.hf,'Style','edit','FontSize',10,'String',num2str(config.scale),'Units','normalized',...
    'Position',[0.96 0.16 0.02 0.05]);

s.epoch_text = uicontrol('Parent',s.hf,'Style','text','FontSize',15,'String','Epoch:','Units','normalized',...
    'Position',[0.05 0.03 0.05 0.05]);
s.epoch_edit = uicontrol('Parent',s.hf,'Style','edit','FontSize',15,'String',num2str(config.epoch_num),'Units','normalized',...
    'Position',[0.1 0.05 0.03 0.04]);
s.epoch_all_text = uicontrol('Parent',s.hf,'Style','text','FontSize',15,'String',['/ ',num2str(length(config.scores))],'Units','normalized',...
    'Position',[0.13 0.03 0.03 0.05]);
s.wake_button = uicontrol('Parent',s.hf,'Style','pushbutton','FontSize',15,'String','W','Units','normalized',...
   'Position',[0.25 0.05 0.05 0.05],'BackgroundColor','c');
s.n1_button = uicontrol('Parent',s.hf,'Style','pushbutton','FontSize',15,'String','N1','Units','normalized',...
    'Position',[0.32 0.05 0.05 0.05],'BackgroundColor','y');
s.n2_button = uicontrol('Parent',s.hf,'Style','pushbutton','FontSize',15,'String','N2','Units','normalized',...
    'Position',[0.39 0.05 0.05 0.05],'BackgroundColor',[255 97 0]/255);
s.n3_button = uicontrol('Parent',s.hf,'Style','pushbutton','FontSize',15,'String','N3','Units','normalized',...
    'Position',[0.46 0.05 0.05 0.05],'BackgroundColor','r');
s.r_button = uicontrol('Parent',s.hf,'Style','pushbutton','FontSize',15,'String','R','Units','normalized',...
    'Position',[0.53 0.05 0.05 0.05],'BackgroundColor','g');
s.unk_button = uicontrol('Parent',s.hf,'Style','pushbutton','FontSize',15,'String','Unknown','Units','normalized',...
    'Position',[0.6 0.05 0.05 0.05],'BackgroundColor',[192,192,192]/255);
s.last_button = uicontrol('Parent',s.hf,'Style','pushbutton','FontSize',15,'String','<','Units','normalized',...
    'Position',[0.7 0.05 0.05 0.05])
s.next_button = uicontrol('Parent',s.hf,'Style','pushbutton','FontSize',15,'String','>','Units','normalized',...
    'Position',[0.75 0.05 0.05 0.05]);
s.done_button = uicontrol('Parent',s.hf,'Style','pushbutton','FontSize',15,'String','Done','Units','normalized',...
    'Position',[0.9 0.05 0.05 0.05]);
%---------------------------------Initialize GUI-----------------------------------------------
set(s.epoch_edit,'callback',{@epoch_edit_callback,s});
set(s.scale_edit,'callback',{@scale_edit_callback,s});
set(s.wake_button,'callback',{@wake_button_callback,s});
set(s.n1_button,'callback',{@n1_button_callback,s});
set(s.n2_button,'callback',{@n2_button_callback,s});
set(s.n3_button,'callback',{@n3_button_callback,s});
set(s.r_button,'callback',{@r_button_callback,s});
set(s.unk_button,'callback',{@unk_button_callback,s});
set(s.last_button,'callback',{@last_button_callback,s});
set(s.next_button,'callback',{@next_button_callback,s});
set(s.done_button,'callback',{@done_button_callback,s});
%----------------------------------Set callback functions--------------
function epoch_edit_callback(hObject,eventdata,s)
global config
num = round(str2num(get(hObject,'string')));
if num > 0 & num < length(config.scores)
    config.epoch_num = num;
    y = -100/config.scale*config.data_check(:,(config.epoch_num-1)*config.srate*30+1:config.epoch_num*config.srate*30)+ repmat([9:-1:0]',1,config.srate*30)*100;
    set(s.plot,{'YData'},num2cell(y,2));
    axes(s.haxes);
    title(config.stages{config.scores(config.epoch_num)},'FontSize',15);
    set(s.epoch_edit,'string',num2str(config.epoch_num));
end


function scale_edit_callback(hObject,eventdata,s)
global config
scale_set = str2num(get(hObject,'string'));
%scale_set
config.scale = scale_set;
y = -100/config.scale*config.data_check(:,(config.epoch_num-1)*config.srate*30+1:config.epoch_num*config.srate*30)+ repmat([9:-1:0]',1,config.srate*30)*100;
%x = 1:30*config.srate;
%axes('Parent',s.hf,'Units','normalized','position',[0.05 0.15 0.9 0.8]);
%axes(s.haxes);
%s.plot = plot(x,y,'b','LineWidth',1.5);
set(s.plot,{'YData'},num2cell(y,2));


function wake_button_callback(hObject,eventdata,s)
global config
if config.epoch_num < length(config.scores)
config.scores(config.epoch_num) = 1;
%set(s.plot,'title', 'W');
config.epoch_num = config.epoch_num+1;
y = -100/config.scale*config.data_check(:,(config.epoch_num-1)*config.srate*30+1:config.epoch_num*config.srate*30)+ repmat([9:-1:0]',1,config.srate*30)*100;
set(s.plot,{'YData'},num2cell(y,2));
axes(s.haxes);
title(config.stages{config.scores(config.epoch_num)},'FontSize',15);
set(s.epoch_edit,'string',num2str(config.epoch_num));
end

function n1_button_callback(hOjbect,eventdata,s)
global config
if config.epoch_num < length(config.scores)
config.scores(config.epoch_num) = 2;
%set(s.plot,'title', 'W');
config.epoch_num = config.epoch_num+1;
y = -100/config.scale*config.data_check(:,(config.epoch_num-1)*config.srate*30+1:config.epoch_num*config.srate*30)+ repmat([9:-1:0]',1,config.srate*30)*100;
set(s.plot,{'YData'},num2cell(y,2));
axes(s.haxes);
title(config.stages{config.scores(config.epoch_num)},'FontSize',15);
set(s.epoch_edit,'string',num2str(config.epoch_num));
end

function n2_button_callback(hOjbect,eventdata,s)
global config
if config.epoch_num < length(config.scores)
config.scores(config.epoch_num) = 3;
%set(s.plot,'title', 'W');
config.epoch_num = config.epoch_num+1;
y = -100/config.scale*config.data_check(:,(config.epoch_num-1)*config.srate*30+1:config.epoch_num*config.srate*30)+ repmat([9:-1:0]',1,config.srate*30)*100;
set(s.plot,{'YData'},num2cell(y,2));
axes(s.haxes);
title(config.stages{config.scores(config.epoch_num)},'FontSize',15);
set(s.epoch_edit,'string',num2str(config.epoch_num));
end

function n3_button_callback(hOjbect,eventdata,s)
global config
if config.epoch_num < length(config.scores)
config.scores(config.epoch_num) = 4;
%set(s.plot,'title', 'W');
config.epoch_num = config.epoch_num+1;
y = -100/config.scale*config.data_check(:,(config.epoch_num-1)*config.srate*30+1:config.epoch_num*config.srate*30)+ repmat([9:-1:0]',1,config.srate*30)*100;
set(s.plot,{'YData'},num2cell(y,2));
axes(s.haxes);
title(config.stages{config.scores(config.epoch_num)},'FontSize',15);
set(s.epoch_edit,'string',num2str(config.epoch_num));
end

function r_button_callback(hOjbect,eventdata,s)
global config
if config.epoch_num < length(config.scores)
config.scores(config.epoch_num) = 5;
%set(s.plot,'title', 'W');
config.epoch_num = config.epoch_num+1;
y = -100/config.scale*config.data_check(:,(config.epoch_num-1)*config.srate*30+1:config.epoch_num*config.srate*30)+ repmat([9:-1:0]',1,config.srate*30)*100;
set(s.plot,{'YData'},num2cell(y,2));
axes(s.haxes);
title(config.stages{config.scores(config.epoch_num)},'FontSize',15);
set(s.epoch_edit,'string',num2str(config.epoch_num));
end

function unk_button_callback(hOjbect,eventdata,s)
global config
if config.epoch_num < length(config.scores)
config.scores(config.epoch_num) = 6;
%set(s.plot,'title', 'W');
config.epoch_num = config.epoch_num+1;
y = -100/config.scale*config.data_check(:,(config.epoch_num-1)*config.srate*30+1:config.epoch_num*config.srate*30)+ repmat([9:-1:0]',1,config.srate*30)*100;
set(s.plot,{'YData'},num2cell(y,2));
axes(s.haxes);
title(config.stages{config.scores(config.epoch_num)},'FontSize',15);
set(s.epoch_edit,'string',num2str(config.epoch_num));
end

function last_button_callback(hObject,eventdata,s)
global config
if config.epoch_num > 1
    config.epoch_num = config.epoch_num-1;
    y = -100/config.scale*config.data_check(:,(config.epoch_num-1)*config.srate*30+1:config.epoch_num*config.srate*30)+ repmat([9:-1:0]',1,config.srate*30)*100;
    set(s.plot,{'YData'},num2cell(y,2));
    axes(s.haxes);
    title(config.stages{config.scores(config.epoch_num)},'FontSize',15);
    set(s.epoch_edit,'string',num2str(config.epoch_num));
end

function next_button_callback(hObject,eventdata,s)
global config
if config.epoch_num < length(config.scores)
    config.epoch_num = config.epoch_num +1;
    y = -100/config.scale*config.data_check(:,(config.epoch_num-1)*config.srate*30+1:config.epoch_num*config.srate*30)+ repmat([9:-1:0]',1,config.srate*30)*100;
    set(s.plot,{'YData'},num2cell(y,2));
    axes(s.haxes);
    title(config.stages{config.scores(config.epoch_num)},'FontSize',15);
    set(s.epoch_edit,'string',num2str(config.epoch_num));
end

function done_button_callback(hObject,eventdata,s)
global config
manual_scores = config.scores-1;
save(config.scoresf,'manual_scores','-ascii');
close(s.hf)
