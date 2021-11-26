function A_PASS
% Written by ZOU Guangyuan 2021.09.26
% Main function of A-PASS: A pipeline to automatically processing ana
% analyzing simultaneous EEG-fMRI data for sleep research.
global A_Cfg
s.hf = figure('toolbar','figure','menubar','none','numbertitle','off',...
    'name','A-PASS','units','normalized','position',[0.4 0.4 0.3 0.2]);
[pathstr,name,ext] = fileparts(which('A_PASS'));
A_Cfg.apassdir = pathstr;
A_Cfg.working_dir = cd;
A_Cfg.subs = [];
A_Cfg.eegtype = '.vhdr';
A_Cfg.MRc = 1;
A_Cfg.BCGc = 1;
A_Cfg.score = 1;
A_Cfg.manualscore = 0;
A_Cfg.dicomsort = 1;
A_Cfg.dicom2nii = 1;
A_Cfg.fmriproc = 1;
A_Cfg.fmri_key = 'sleep';
A_Cfg.t1_key = 't1';
A_Cfg.ep_length = 300;
A_Cfg.TR = 0;
A_Cfg.sliceorder = [1:2:33,2:2:33];
A_Cfg.pyenv = 'default';
A_Cfg.ALFF = 1;
A_Cfg.ReHo = 1;
A_Cfg.DC = 1;
A_Cfg.VMHC = 1;
A_Cfg.FC = 1;
A_Cfg.ROIlist = {''};
A_Cfg.stat = 1;
A_Cfg.voxelp = 0.001;
A_Cfg.clusterp = 0.05;
A_Cfg.conda_path = '';
A_Cfg.conda_env = 0;
%-------------------------A_Cfg default settings--------------------
s.logo_text = uicontrol('Parent',s.hf,'Style','text','String','A-PASS','FontSize',30,'ForegroundColor',[4 88 160]/255,'Units','normalized',...
    'position', [0.1 0.7 0.8 0.2],'FontAngle','italic','FontWeight','bold');
s.working_dir_text = uicontrol('parent',s.hf,'style','text','string','Working directory:','FontSize',12,'units','normalized',...
    'position',[0.05 0.5 0.3 0.1]);
s.working_dir_edit = uicontrol('parent',s.hf,'style','edit','units','normalized','string',cd,...
    'position',[0.35 0.5 0.3 0.1]);
s.working_dir_pushbutton = uicontrol('parent',s.hf,'style','pushbutton','string','Open','units','normalized',...
    'position',[0.7 0.5 0.1 0.1],'FontSize',12);

s.manualscore_check = uicontrol('parent',s.hf,'style','checkbox','string','Manual check for stages','FontSize',12,'units','normalized',...
    'position',[0.1 0.3 0.5 0.1]);

s.run_button = uicontrol('Parent',s.hf,'Style','pushbutton','String','Run','FontSize',12,'Units','normalized',...
    'Position',[0.7 0.3 0.1 0.1]);%'FontWeight','bold',
%--------------------------------------------setup-----------------------------------------
set(s.working_dir_edit,'callback',{@working_dir_edit_callback,s});
set(s.working_dir_pushbutton,'callback',{@working_dir_pushbutton_callback,s});

set(s.manualscore_check,'callback',{@manualscore_check_callback,s});
set(s.run_button,'callback',{@run_button_callback,s});

%-----------------------------set callbacks------------------------
function working_dir_edit_callback(hObject,eventdata,s)
global A_Cfg
dirname = get(hObject,'String');
if ischar(dirname)
    A_Cfg.working_dir = dirname;
    set(s.working_dir_edit,'string',dirname);
end

function working_dir_pushbutton_callback(hObject,eventdata,s);
global A_Cfg
dirname = uigetdir(cd,'Working directory');
if ischar(dirname)
    A_Cfg.working_dir = dirname;
    set(s.working_dir_edit,'String',dirname);
end

function manualscore_check_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.manualscore = (get(hObject,'value'));




function run_button_callback(hObject, eventdata, s)
global A_Cfg
[pathstr,name,ext] = fileparts(which('A_PASS'));
A_Cfg.apassdir = pathstr;
Cfg = A_Cfg;
save(fullfile(Cfg.working_dir,['APASSpara.mat']),'Cfg');
set(s.run_button,'enable','off');
pause(0.5)
rtpath = Cfg.working_dir;

if isempty(Cfg.subs)
    subs_dir = dir([rtpath,'sub*']);
    subs = [];
    for i = 1:length(subs_dir)
        subs=[subs,' ',subs_dir(i).name];
    end
else
    subs = [];
    subs_n = Cfg.subs
    for i = 1:length(subs_n)
        subs = [subs,' sub',num2str(subs_n(i),'%02d')];
    end
end

cd(rtpath)
delete('pval.txt');
fi = fopen('pval.txt','w');
fprintf(fi,[num2str(Cfg.voxelp),'\n']);
fprintf(fi,[num2str(Cfg.clusterp),'\n']);
fclose(fi);


cd(Cfg.apassdir)
if Cfg.MRc+Cfg.BCGc+Cfg.score+Cfg.manualscore+Cfg.dicomsort+Cfg.dicom2nii+Cfg.fmriproc>0
    subs_command = ['bash pipe_group_sub.sh -a ''',Cfg.apassdir,''' -b ''',rtpath,''' -c ''',subs,''' -d ',num2str(Cfg.MRc),...
        ' -e ',num2str(Cfg.BCGc),' -f ',num2str(Cfg.score),' -g ',num2str(Cfg.manualscore),' -h ',num2str(Cfg.dicomsort),...
        ' -i ',num2str(Cfg.dicom2nii),' -j ',num2str(Cfg.fmriproc),' -k ',Cfg.pyenv, ' -l ',Cfg.conda_path,' 2>&1'];
    [stateid,cmdout] = system(subs_command)
end
if Cfg.stat == 1
    
    stats_command = ['bash pipe_group_stats.sh -a ''', Cfg.apassdir,''' -r ''', rtpath,''' -s ''', subs,''' 2>&1'];
    [stateid2,cmdout2]=system(stats_command)
    correct_command = ['bash pipe_group_correct.sh -r ', rtpath];
    [stateid3,cmdout3]=system(correct_command)
end
set(s.run_button,'enable','on');



