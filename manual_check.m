%Written by ZOU Guangyuan, 2021.09.26
%Manual sleep stage scoring in A-PASS using check_eeg.m.
%apassdir: path of A-PASS
%root: path of working directory

addpath(genpath(fullfile(apassdir,'/toolboxes/eeglab14_1_1b')));
addpath(fullfile(apassdir))
%work_dir='/disk1/guangyuan/CMRServer148/testpipeline2/sub06/cleaned_EEGdata/sub06/';
%cd(work_dir);
eegfiles= dir('*vhdr');
scorefiles=dir('stage*txt');


for i=1:length(eegfiles)
    check_eeg(apassdir,root,eegfiles(i).name,scorefiles(i).name);
    uiwait();
end