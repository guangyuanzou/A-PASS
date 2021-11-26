function A_PASS
% Written by ZOU Guangyuan 2021.09.26
% Main function of A-PASS: A pipeline to automatically processing ana
% analyzing simultaneous EEG-fMRI data for sleep research.
global A_Cfg
s.hf = figure('toolbar','figure','menubar','none','numbertitle','off',...
    'name','A-PASS','units','normalized','position',[0.1 0.1 0.4 0.7]);
[pathstr,name,ext] = fileparts(which('A_PASS'));
A_Cfg.apassdir = pathstr;
A_Cfg.working_dir = cd;
A_Cfg.subs = [];
%A_Cfg.eegtype = '.vhdr';
A_Cfg.MRc = 1;
A_Cfg.BCGc = 1;
A_Cfg.score = 1;
A_Cfg.manualscore = 0;
%A_Cfg.dicomsort = 0;
A_Cfg.dicom2nii = 1;
A_Cfg.fmriproc = 1;
A_Cfg.fmri_key = 'leep';
A_Cfg.t1_key = 't1';
A_Cfg.ep_length = 300;
A_Cfg.TR = 0;
A_Cfg.sliceorder = 0;
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
%A_Cfg.conda_path = '';
%A_Cfg.conda_env = 0;
%-------------------------A_Cfg default settings--------------------
s.logo_text = uicontrol('Parent',s.hf,'Style','text','String','A-PASS','FontSize',30,'ForegroundColor',[4 88 160]/255,'Units','normalized',...
    'position', [0.1 0.85 0.8 0.1],'FontAngle','italic','FontWeight','bold');
s.working_dir_text = uicontrol('parent',s.hf,'style','text','string','Working directory:','FontSize',12,'units','normalized',...
    'position',[0.1 0.8 0.2 0.03],'HorizontalAlignment','left');
s.working_dir_edit = uicontrol('parent',s.hf,'style','edit','units','normalized','string',cd,...
    'position',[0.3 0.8 0.4 0.04]);
s.working_dir_pushbutton = uicontrol('parent',s.hf,'style','pushbutton','string','Open','units','normalized',...
    'position',[0.77 0.8 0.15 0.04],'FontSize',12);
s.subs_text = uicontrol('parent',s.hf,'style','text','string','Subjects:','FontSize',12,'units','normalized',...
    'position',[0.1 0.75 0.2 0.03],'HorizontalAlignment','left');
s.subs_edit = uicontrol('parent',s.hf,'style','edit','units','normalized','string','*',...
    'position',[0.3 0.75 0.4 0.04]);

%s.eeg_frame = uicontrol('Parent',s.hf,'Style','frame','Units','normalized','Position',[0.1 0.63 0.82 0.08]);
s.eegpre_check = uicontrol('Parent',s.hf,'Style','checkbox','String','EEG preprocessing','FontSize',12,'Units','normalized',...
    'Position',[0.08 0.7 0.23 0.03],'Value',1,'FontWeight','bold');
%s.eegtype_text = uicontrol('parent',s.hf,'style','text','string','EEG type:','Fontsize',12,'units','normalized',...
    %'position',[0.05 0.7 0.2 0.03]);
%s.eegtype_pop= uicontrol('parent',s.hf,'style','popupmenu','string',{'.vhdr';'.edf';'.CNT'},'units','normalized',...
    %'position',[0.25 0.7 0.1 0.03]);
%s.MRc_check = uicontrol('parent',s.hf,'style','checkbox','string','MR artifact correction','FontSize',12,'units','normalized',...
    %'position',[0.13 0.65 0.25 0.03],'Value',1);
%s.BCGc_check = uicontrol('parent',s.hf,'style','checkbox','string','BCG artifact correction','FontSize',12,'units','normalized',...
    %'position',[0.40 0.65 0.25 0.03],'Value',1);
s.score_frame = uicontrol('Parent',s.hf,'Style','frame','Units','normalized','Position',[0.1 0.58 0.82 0.08]);
s.is_score = uicontrol('Parent',s.hf,'Style','checkbox','String','Sleep stage scoring','Units','normalized','FontSize',12,...
    'Position',[0.08 0.65 0.25 0.03],'FontWeight','bold','Value',1)
s.score_check = uicontrol('parent',s.hf,'style','checkbox','string','Automatic scoring','FontSize',12,'units','normalized',...
    'position',[0.13 0.6 0.2 0.03],'Value',1);

s.manualscore_check = uicontrol('parent',s.hf,'style','checkbox','string','Manual check','FontSize',12,'units','normalized',...
    'position',[0.48 0.6 0.2 0.03]);


s.fMRI_frame = uicontrol('Parent',s.hf,'Style','frame','Units','normalized','Position',[0.1, 0.21 0.82 0.33]);
%s.dicomsort_check = uicontrol('parent',s.hf,'style','checkbox','string','DICOM sort','FontSize',12,'units','normalized',...
    %'position',[0.1 0.45 0.2 0.03],'Value',1);
s.fmriproc_check = uicontrol('parent',s.hf,'style','checkbox','string','fMRI processing','FontSize',12,'units','normalized',...
    'position',[0.08 0.53 0.2 0.03],'Value',1,'FontWeight','bold');
    
s.dicom2nii_check = uicontrol('parent',s.hf,'style','checkbox','string','DICOM to NIFTI','FontSize',12,'units','normalized',...
    'position',[0.13 0.48 0.2 0.03],'Value',1);
%s.fmri_key_text = uicontrol('parent',s.hf,'style','text','string','Key word of sleep series:','Fontsize',12,'units','normalized',...
    %'position',[0.1 0.3 0.25 0.03],'HorizontalAlignment','left');
%s.fmri_key_edit = uicontrol('parent',s.hf,'style','edit','string','sleep','units','normalized',...
    %'position',[0.35 0.3 0.1 0.03]);
%s.t1_key_text = uicontrol('parent',s.hf,'style','text','string','Key word of t1 series:','Fontsize',12,'units','normalized',...
    %'position',[0.1 0.25 0.25 0.03],'HorizontalAlignment','left');
%s.t1_key_edit = uicontrol('parent',s.hf,'style','edit','string','t1','units','normalized',...
    %'position',[0.35 0.25 0.1 0.03]);
s.ep_length_text = uicontrol('parent',s.hf,'style','text','string','fMRI episode length(s):','FontSize',12,'units','normalized',...
    'position',[0.48 0.48 0.25 0.03],'HorizontalAlignment','left');
s.ep_length_edit = uicontrol('parent',s.hf,'style','edit','string','300','units','normalized',...
    'position',[0.73 0.48 0.15 0.03]);
%s.TR_text = uicontrol('parent',s.hf,'style','text','string','TR(s):','FontSize',12,'units','normalized',...
    %'position',[0.13 0.43 0.1 0.03],'HorizontalAlignment','left');
%s.TR_edit = uicontrol('parent',s.hf,'style','edit','units','normalized','String','0',...
    %'position',[0.23 0.43 0.1 0.03]);
%s.sliceorder_text = uicontrol('parent',s.hf,'style','text','string','Slice order:','FontSize',12,'units','normalized',...
    %'position',[0.48 0.43 0.25 0.03],'HorizontalAlignment','left');
%s.sliceorder_edit = uicontrol('parent',s.hf,'Style','edit','String',num2str([1:2:33,2:2:33]),'units','normalized',...
    %'position',[0.73 0.43 0.15 0.03]);
s.metric_frame = uicontrol('Parent',s.hf,'Style','frame','Units','normalized','Position',[0.13 0.23 0.76 0.21]);
s.metric_check = uicontrol('Parent',s.hf,'Style','checkbox','String','fMRI metrics','Units','normalized','FontSize',12,...
    'Position',[0.13 0.43 0.15 0.03],'HorizontalAlignment','left','Value',1);    
    
s.ALFF_check = uicontrol('parent',s.hf,'Style','checkbox','String','ALFF&fALFF','FontSize',12,'Units','normalized',...
    'Position',[0.15 0.38 0.2 0.03],'Value',1);
s.ReHo_check = uicontrol('Parent',s.hf,'Style','checkbox','String','ReHo','FontSize',12,'Units','normalized',...
    'Position',[0.35 0.38 0.15 0.03],'Value',1);
s.DC_check = uicontrol('Parent',s.hf,'Style','checkbox','String','Degree centrality','FontSize',12,'Units','normalized',...
    'Position',[0.50 0.38 0.2 0.03],'Value',1);
s.VMHC_check = uicontrol('Parent',s.hf,'Style','checkbox','String','VMHC','FontSize',12,'Units','normalized',...
    'Position',[0.75 0.38 0.13 0.03],'Value',1);
s.FC_check = uicontrol('Parent',s.hf,'Style','checkbox','String','Funtional connectivity','FontSize',12,'Units','normalized',...
    'Position',[0.15 0.33 0.3 0.03],'Value',1);
s.ROIadd_button = uicontrol('Parent',s.hf,'Style','pushbutton','String','Add ROI','FontSize',12,'Units','normalized',...
    'Position',[0.6 0.28 0.15 0.04]);
s.ROIremove_button = uicontrol('Parent',s.hf,'Style','pushbutton','String','Remove ROI','FontSize',12,'Units','normalized',...
    'Position',[0.6 0.24 0.15 0.04]);
s.ROI_text = uicontrol('Parent',s.hf,'Style','text','string','ROI list:','FontSize',12,'Units','normalized',...
    'Position',[0.2 0.26 0.1 0.03],'HorizontalAlignment','left');
s.ROI_list = uicontrol('Parent',s.hf,'Style','list','string',{},'Units','normalized',...
    'Position',[0.3 0.24 0.3 0.08]);

s.stat_frame = uicontrol('Parent',s.hf,'Style','frame','Units','normalized','Position',[0.1,0.09, 0.82 ,0.08]);
s.stat_check = uicontrol('Parent',s.hf,'Style','checkbox','String','Statistics','FontSize',12,'Units','normalized',...
    'Position',[0.08 0.16 0.15 0.03],'Value',1,'FontWeight','bold');
s.voxelp_text = uicontrol('Parent',s.hf,'Style','text','String','Voxelwise p:','FontSize',12,'Units','normalized',...
    'Position',[0.13 0.11 0.15 0.03],'HorizontalAlignment','left');
s.voxelp_pop = uicontrol('Parent',s.hf,'Style','popupmenu','String',{'0.001','0.01','0.05'},'FontSize',12,'Units','normalized',...
    'Position',[0.28 0.11 0.15 0.03]);
s.clusterp_text = uicontrol('Parent',s.hf,'Style','text','String','Clusterwise p:','FontSize',12,'Units','normalized',...
    'Position',[0.48 0.11 0.15 0.03],'HorizontalAlignment','left');
s.clusterp_pop = uicontrol('Parent',s.hf,'Style','popupmenu','String',{'0.05','0.01','0.001'},'FontSize',12,'Units','normalized',...
    'Position',[0.63 0.11 0.15 0.03]);
%s.conda_check = uicontrol('Parent',s.hf,'Style','checkbox','String','Use conda environment','FontSize',12,'Units','normalized',...
    %'Position',[0.55 0.3 0.4 0.03],'Value',0);
%s.conda_text = uicontrol('Parent',s.hf,'Style','text','String','Full path of conda.sh:','FontSize',12,'Units','normalized',...
    %'Position',[0.55 0.25 0.3 0.03],'HorizontalAlignment','left');
%s.conda_edit = uicontrol('Parent',s.hf,'Style','edit','Units','normalized',...
    %'Position',[0.8 0.25 0.15 0.03],'Enable','off');
%s.pyenv_text = uicontrol('Parent',s.hf,'Style','text','String','Python environment name:','FontSize',12,'Units','normalized',...
    %'Position',[0.55 0.2 0.3 0.03],'HorizontalAlignment','left');
%s.pyenv_edit = uicontrol('Parent',s.hf,'Style','edit','Units','normalized',...
    %'Position',[0.8 0.2 0.15 0.03],'Enable','off');


s.save_button = uicontrol('Parent',s.hf,'Style','pushbutton','String','Save','FontSize',12,'Units','normalized',...
    'Position',[0.08 0.03 0.15 0.04]);
s.load_button = uicontrol('Parent',s.hf,'Style','pushbutton','String','Load','FontSize',12,'Units','normalized',...
    'Position',[0.23 0.03 0.14 0.04]);
s.run_button = uicontrol('Parent',s.hf,'Style','pushbutton','String','Run','FontSize',12,'Units','normalized',...
    'Position',[0.77 0.03 0.15 0.04]);%'FontWeight','bold',
%---------------------------------------------setup-----------------------------------------
set(s.working_dir_edit,'callback',{@working_dir_edit_callback,s});
set(s.working_dir_pushbutton,'callback',{@working_dir_pushbutton_callback,s});
set(s.subs_edit,'callback',{@subs_edit_callback,s});
%set(s.eegtype_pop,'callback',{@eegtype_pop_callback,s});
set(s.eegpre_check,'callback',{@eegpre_check_callback,s});
set(s.MRc_check,'callback',{@MRc_check_callback,s});
set(s.BCGc_check,'callback',{@BCGc_check_callback,s});
set(s.score_check,'callback',{@score_check_callback,s});
set(s.manualscore_check,'callback',{@manualscore_check_callback,s});
%set(s.dicomsort_check,'callback',{@dicomsort_check_callback,s});
set(s.dicom2nii_check,'callback',{@dicom2nii_check_callback,s});
set(s.fmriproc_check,'callback',{@fmriproc_check_callback,s});
%set(s.fmri_key_edit,'callback',{@fmri_key_edit_callback,s});
%set(s.t1_key_edit,'callback',{@t1_key_edit_callback,s});
set(s.ep_length_edit,'callback',{@ep_length_edit_callback,s});
set(s.TR_edit,'callback',{@TR_edit_callback,s});
set(s.sliceorder_edit,'callback',{@sliceorder_edit_callback,s});

set(s.ALFF_check,'callback',{@ALFF_check_callback,s});
set(s.ReHo_check,'callback',{@ReHo_check_callback,s});
set(s.DC_check,'callback',{@DC_check_callback,s});
set(s.VMHC_check,'callback',{@VMHC_check_callback,s});
set(s.FC_check,'callback',{@FC_check_callback,s});
set(s.ROIadd_button,'callback',{@ROIadd_button_callback,s});
set(s.ROIremove_button,'callback',{@ROIremove_button_callback,s});
set(s.stat_check,'callback',{@stat_check_callback,s});
set(s.voxelp_pop,'callback',{@voxelp_pop_callback,s});
set(s.clusterp_pop,'callback',{@clusterp_pop_callback,s});
%set(s.conda_check,'callback',{@conda_check_callback,s});
%set(s.pyenv_edit,'callback',{@pyenv_edit_callback,s});
%set(s.conda_edit,'callback',{@conda_edit_callback,s});
set(s.save_button,'callback',{@save_button_callback,s});
set(s.load_button,'callback',{@load_button_callback,s});
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


function subs_edit_callback(hObject,eventdata,s);
global A_Cfg
subs_id = get(hObject,'String');
subs_id = str2num(subs_id);
A_Cfg.subs = subs_id;

function eegtype_pop_callback(hObject,eventdata,s);
global A_Cfg
value = get(hObject,'Value');
switch value
    case 1
        A_Cfg.eegtype = '.vhdr';
    case 2
        A_Cfg.eegtype = '.edf';
    case 3
        A_Cfg.eegtype = '.CNT';
end

function MRc_check_callback(hObject,eventdata,s);
global A_Cfg
A_Cfg.MRc = (get(hObject,'value'));

function BCGc_check_callback(hObject,eventdata,s);
global A_Cfg
A_Cfg.BCGc = (get(hObject,'value'));

function score_check_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.score = (get(hObject,'value'));

function manualscore_check_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.manualscore = (get(hObject,'value'));

function dicomsort_check_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.dicomsort = (get(hObject,'value'));
    
function dicom2nii_check_callback(hObject,eventdata,s);
global A_Cfg
A_Cfg.dicom2nii = (get(hObject,'value'));

function fmriproc_check_callback(hObject,eventdata,s);
global A_Cfg
A_Cfg.fmriproc = (get(hObject,'value'));

function fmri_key_edit_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.fmri_key = get(hObject,'string');

function t1_key_edit_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.t1_key = get(hObject,'string');

function ep_length_edit_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.ep_length = str2num(get(hObject,'string'));

function TR_edit_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.TR = str2num(get(hObject,'string'));

function sliceorder_edit_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.sliceorder = str2num(get(hObject,'string'));

function conda_check_callback(hObject,eventdata,s)
global A_Cfg
set(s.pyenv_edit,'Enable','On');
set(s.conda_edit,'Enable','On');
A_Cfg.conda_env = 1;

function pyenv_edit_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.pyenv = get(hObject,'string');

function conda_edit_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.conda_path=get(hObject,'string');

function ALFF_check_callback(hObject,eventdata,s);
global A_Cfg
A_Cfg.ALFF = (get(hObject,'value'));

function ReHo_check_callback(hObject,eventdata,s);
global A_Cfg
A_Cfg.ReHo = (get(hObject,'value'));

function DC_check_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.DC = (get(hObject,'value'));

function VMHC_check_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.VMHC = (get(hObject,'value'));

function FC_check_callback(hObject,eventdata,s);
global A_Cfg
A_Cfg.FC = (get(hObject,'value'));

function ROIadd_button_callback(hObject,eventdata,s)
global A_Cfg
[filename pathname] = uigetfile({'*.nii';'*.hdr'},'Select ROI file');
if ischar(filename)
    roilist = get(s.ROI_list,'string');
    if length(A_Cfg.ROIlist{1})==0
        roilist = {[pathname filename]};
    else
        
        roilist = [roilist;[pathname filename]];
    end
    set(s.ROI_list,'string',roilist,'value',1);
    A_Cfg.ROIlist = get(s.ROI_list,'string');
end

function ROIremove_button_callback(hObject,eventdata,s)
global A_Cfg
roi_sel = get(s.ROI_list,'value');
roilist = get(s.ROI_list,'string');
roilist(roi_sel) = [];
set(s.ROI_list,'value',1)
set(s.ROI_list,'string',roilist);
A_Cfg.ROIlist = get(s.ROI_list,'string');

function stat_check_callback(hObject,eventdata,s)
global A_Cfg
A_Cfg.stat = (get(hObject,'value'));

function voxelp_pop_callback(hObject,eventdata,s)
global A_Cfg
value = get(hObject,'value');
switch value
    case 1
        A_Cfg.voxelp = 0.001;
    case 2
        A_Cfg.voxelp = 0.01;
    case 3
        A_Cfg.voxelp = 0.05;
end

function clusterp_pop_callback(hObject,eventdata,s)
global A_Cfg
value = get(hObject,'value');
switch value
    case 1
        A_Cfg.clusterp = 0.05;
    case 2
        A_Cfg.clusterp = 0.01;
    case 3
        A_Cfg.clusterp = 0.001;
end

function save_button_callback(hObject,eventdata,s)
global A_Cfg
Cfg = A_Cfg;
[filename pathname] = uiputfile({'*.mat'},'Save as');
if ischar(filename)
    save([pathname,filename],'Cfg');
end

function load_button_callback(hObject,eventdata,s)
global A_Cfg
[filename pathname] = uigetfile({'*.mat'},'Load from');
if ischar(filename)
    load([pathname filename]);
    set(s.working_dir_edit,'string',Cfg.working_dir);
    set(s.subs_edit,'string',num2str(Cfg.subs))
    if strcmp(Cfg.eegtype,'.vhdr')
        %set(s.eegtype_pop,'string',{'.vhdr','.edf','.CNT'});
        set(s.eegtype_pop,'Value',1);
    elseif strcmp(Cfg.eegtype,'.edf')
        %set(s.eegtype_pop,'string',{'.vhdr','.edf','.CNT'});
        %get(s.eegtype_pop,'string')
        set(s.eegtype_pop,'Value',2);
    elseif strcmp(Cfg.eegtype,'.CNT');
        %set(s.eegtype_pop,'string',{'.vhdr','.edf','.CNT'});
        set(s.eegtype_pop,'Value',3);
    end
   
    set(s.MRc_check,'value',Cfg.MRc);
    set(s.BCGc_check,'value',Cfg.BCGc);
    set(s.score_check,'value',Cfg.score);
    set(s.manualscore_check,'value',Cfg.manualscore);
    set(s.dicomsort_check,'value',Cfg.dicomsort);
    set(s.dicom2nii_check,'value',Cfg.dicom2nii);
    set(s.fmriproc_check,'value',Cfg.fmriproc);
    set(s.fmri_key_edit,'string',Cfg.fmri_key);
    set(s.t1_key_edit,'string',Cfg.t1_key);
    set(s.ep_length_edit,'string',num2str(Cfg.ep_length));
    set(s.TR_edit,'string',num2str(Cfg.TR));
    set(s.sliceorder_edit,'string',num2str(Cfg.sliceorder));
    set(s.pyenv_edit,'string',Cfg.pyenv);
    set(s.conda_edit,'string',Cfg.conda_path);
    set(s.ALFF_check,'value',Cfg.ALFF);
    set(s.ReHo_check,'value',Cfg.ReHo);
    set(s.DC_check,'value',Cfg.DC);
    set(s.VMHC_check,'value',Cfg.VMHC);
    set(s.FC_check,'value',Cfg.FC);
    set(s.ROI_list,'string',Cfg.ROIlist);
    set(s.stat_check,'value',Cfg.stat);
    set(s.conda_check,'value',Cfg.conda_env);
    if Cfg.conda_env==1
    set(s.pyenv_edit,'enable','on');
    set(s.conda_edit,'enable','on');
    end
    if Cfg.voxelp == 0.001
        set(s.voxelp_pop,'value',1);
    elseif Cfg.voxelp == 0.01
        set(s.voxelp_pop,'value',2);
    elseif Cfg.voxelp == 0.05
        set(s.voxelp_pop,'value',3);
    end
    if Cfg.clusterp == 0.05
        set(s.clusterp_pop,'value',1);
    elseif Cfg.clusterp == 0.01
        set(s.clusterp_pop,'value',2);
    elseif Cfg.clusterp == 0.001
        set(s.clusterp_pop,'value',3);
    end
    A_Cfg = Cfg;
end

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



