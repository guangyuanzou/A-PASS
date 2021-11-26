% Written by ZOU Guangyuan, 2021.09.26
% EEG data preprocessing (MR artifact correction, Downsampling, Filtering,
% Abondon first 10 Volumns, Saving data as multiples of 30-s-epoch).
% root: path of working directory
% ------------------------------------------------
cd(root)
cd ..
apassmat = dir('APASSpar*');
apasscfg = load(apassmat(end).name);
addpath(genpath(fullfile(apasscfg.Cfg.apassdir,'/toolboxes/eeglab14_1_1b')));
addpath(fullfile(apasscfg.Cfg.apassdir));
cd(root)
eeglab nogui;

cd(root)

eegtype='';
f=dir(['*vhdr']);
eegtype='.vhdr';
if length(f)==0
    f=dir(['*edf']);
    eegtype='.edf'
end
if length(f)==0
    f=dir(['*CNT']);
    eegtype='.CNT';
end
f={f.name};
f=sort_nat(f);

for file_n=1:length(f)
    cd(root)
    if strcmp(eegtype,'.vhdr')
        EEG = pop_loadbv('.',f{file_n});
    elseif strcmp(eegtype,'.edf')
        EEG = pop_biosig('.',f{file_n});
    elseif strcmp(eetype,'.CNT')
        EEG = pop_loadcnt('.',f{file_n});
    else
        error('No recognized EEG file');
        quit()
    end
    EEG = eeg_checkset( EEG );
    %load data
    clear timd_un
    idmarks=find(strcmp({EEG.event.type},'R128')==1);
    tim = [EEG.event(idmarks).latency];
    timd = diff(tim);
    timd_u = unique(timd);
    for i=1:length(timd_u)
        timd_un(i)=length(find(timd==timd_u(i)));
    end
    [timd_un, seq] = sort(timd_un);
    timd_u = timd_u(seq);
    if length(timd_un)>1
        xi=[0, EEG.pnts-1];
        for i=1:length(timd_un)-1
            id_seg = find(timd==timd_u(i));
            for j=1:length(id_seg)
                xi = [xi, round(mean(tim(id_seg(j):id_seg(j)+1)))];
            end
            
        end
        xi=sort(xi);
        xi_d = diff(xi);
        max_pid = find(xi_d==max(xi_d));
        start_point = xi(max_pid);
        end_point = xi(max_pid+1);
        EEG = pop_select(EEG,'point',[start_point,end_point]);
        
    end
    % for those EEG data oontains multiple segments, the longest is regarded as sleep segment. 
    r128_s = find(strcmp({EEG.event.type},'R128')==1);
    last_r128_lat = EEG.event(r128_s(end)).latency;
    if EEG.pnts - last_r128_lat < last_r128_lat - EEG.event(r128_s(end-1)).latency;
        EEG = pop_select(EEG,'point',[1,EEG.event(r128_s(end)).latency-1]);
    end
    
    
    
    other_c=strfind({EEG.chanlocs(:).labels},'E');
    other_c=~cellfun(@isempty,other_c);
    other_channel_id=find(other_c);
    try
        EEG = pop_fmrib_fastr(EEG,0,1,21,'R128',0,0,0,0,0,0.03,other_channel_id,0);
    catch
        try
            EEG = pop_fmrib_fastr(EEG,0,1,60,'R128',0,0,0,0,0,0.03,other_channel_id,0);
        catch
            EEG = pop_select( EEG, 'time',[0 floor(EEG.xmax/10)*10]-0.1);
            EEG = pop_fmrib_fastr(EEG,0,1,21,'R128',0,0,0,0,0,0.03,other_channel_id,0);
        end
    end
    EEG = eeg_checkset( EEG );
    %MR correction
    
    EEG = pop_resample( EEG, 100);
    EEG = eeg_checkset( EEG );
  
    EEG = pop_eegfiltnew(EEG, 0.3,35)%,5500,0,[],0);
    EEG = eeg_checkset( EEG );
    %filtering with 0.3-35 Hz
    
    id=find(strcmp({EEG.event.type},'R128')==1);
    st_point=EEG.event(id(11)).latency;
    ed_point=floor((EEG.event(id(end)).latency-st_point)/3000)*3000+st_point-1;
    EEG = pop_select( EEG, 'point',[st_point ed_point] ); 
    % This should be calculated considering the epochs needed for further analysis
    % segment the data to extract part needed for further analysis
    EEG = eeg_checkset( EEG );

    sub=strsplit(root,'/');
    sub_name=sub{end};
    cd(root)
    mkdir('MRcEEGdata');
    cd('MRcEEGdata');
    mkdir(sub_name)
    cd(sub_name)
    pop_saveset(EEG,'filename',[sub_name,'_r0',num2str(file_n),'_raw.set']);
end
% write data as set format to be used in python for automatic sleep staging.
quit()

