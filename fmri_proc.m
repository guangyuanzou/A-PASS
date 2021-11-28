% Written by ZOU Guangyuan, 2021.09.26
% fMRI processing in A-PASS, adopting DPABI(DPARSFA)
% Reference: 
% Yan, C.G., Wang, X.D., Zuo, X.N., Zang, Y.F., 2016. 
% DPABI: Data Processing & Analysis for (Resting-State) Brain Imaging. 
% Neuroinformatics 14, 339-351. doi: 10.1007/s12021-016-9299-4
% 
% root: subject folder, e.g., /disk1/project01/sub01/'
% apassdir: path of A-PASS
addpath(genpath([apassdir,'/toolboxes/DPABI_V4.3_200401/']));
addpath(genpath([apassdir,'/toolboxes/SPM12/']));
load([apassdir,'/DPARSFA_templcomp.mat']);
% load DPARSFA template
cd(root)
cd ..
TR=0;
sliceorder = 0;
if ~exist('TR.txt','file')==0
    TR=load('TR.txt');
end

if ~exist('SliceOrder.txt')==0
    sliceorder=load('SliceOrder.txt');
end

ap = load(['APASSpara.mat']);
cd(root)
cd('nii');

if TR==0|sliceorder==0
    jsonf = [dir('*sleep*.json');dir('*Sleep*.json');dir('*SLEEP*.json')];
    if isempty(strfind(jsonf(1).name,'t1'))==1
    f=fopen(jsonf(1).name);
    else
        f=fopen(jsonf(2).name);
    end
    raw=fread(f,inf);
    str=char(raw');
    struc=jsondecode(str);
    if TR==0
        TR=struc.RepetitionTime;
    end
    
    if sliceorder==0
        [slicetime,id]=sort(struc.SliceTiming);
        sliceorder=id;
    end
    fclose(f);
end


if TR==0
    error('No TR information');
    quit()
end
if sliceorder==0
    error('NO slice order information');
    quit()
end

Funs=dir('*FunImg');
rt=cd;

Cfg.WorkingDir=rt;
Cfg.DataProcessDir=rt;
Cfg.FunctionalSessionNumber=length(Funs);
%Cfg.TR = ap.Cfg.TR;
Cfg.TR = TR;
Cfg.SliceTiming.SliceOrder = sliceorder;
Cfg.SliceTiming.SliceNumber = length(sliceorder);
Cfg.SliceTiming.ReferenceSlice = sliceorder(ceil(length(sliceorder)/2));

if ap.Cfg.metrics==1
Cfg.IsCalALFF = ap.Cfg.ALFF;
Cfg.IsCalFC = ap.Cfg.FC;
Cfg.IsCalVMHC = ap.Cfg.VMHC;
Cfg.CalFC.ROIDef = ap.Cfg.ROIlist;
end
% set fMRI parameters according to A-PASS settings
tic
try
DPARSFA_run(Cfg,[],[],0);
end
toc
%ALFF&fALFF,FC,VMHC processing



load([apassdir,'/DPARSFA_templcomp_rehodc.mat']);
cd(root);
cd('nii');
if ap.Cfg.metric_check==1
Cfg.WorkingDir=rt;
Cfg.DataProcessDir=rt;
Cfg.FunctionalSessionNumber=length(Funs);

%Cfg.TR= ap.Cfg.TR;
%Cfg.SliceTiming.SliceOrder = ap.Cfg.sliceorder;
Cfg.IsCalReHo = ap.Cfg.ReHo;
Cfg.IsCalDegreeCentrality = ap.Cfg.DC;

try
    DPARSFA_run(Cfg,[],[],0);
end
%ReHo,DC processing
end

addpath(apassdir);
cd(root)
load('APASSpara.mat');
if isempty(Cfg.subs) 
   subs=dir('sub*');
else
    for i=1:length(Cfg.subs);
        subs(i).name=['sub',num2str(Cfg.subs(i),'%02d')];
    end
end
%rmdir('stats','s');

quit()