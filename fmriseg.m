
% Written by ZOU Guangyuan, 2021.09.26
% Segment fMRI data to episodes with equal length for resting-state
% fMRI analysis in A-PASS.

% root: subject folder, e.g.,/disk1/project01/sub01/)
% apassdir: path of A-PASS
% sub_name: e.g. sub01


addpath(genpath([apassdir,'/toolboxes/SPM12']));
cd(root)
cd('nii')
alld=dir();
for i=3:length(alld)
    if alld(i).isdir==1&strcmp(alld(i).name,'.')==0&strcmp(alld(i).name,'..')==0
        rmdir(alld(i).name,'s');
    end
end
cd(root)
cd ..
TR=0;
if ~exist('TR.txt','file')==0
    TR=load('TR.txt');
end
load('APASSpara.mat');
ep_length = Cfg.ep_length;
%TR = Cfg.TR;
fmri_key = 'leep';%Cfg.fmri_key;
t1_key = 't1';%Cfg.t1_key;
% load APASSpara.mat to get fmri processing parameters.
cd(root)
cd('cleaned_EEGdata');
cd(sub_name)
f=dir('*.txt');     
%read txt files: scoring results                       
lf =length(f);




dpabi_num=0;
filenames={};
num_dir=0;
for file_n = 1:lf
    cd(root)
    cd('cleaned_EEGdata');
    cd(sub_name)


    inds=zeros(5,10000);
    a=load(f(file_n).name);
   
    for j=1:5% 5 if REM also exists;4 if no REM
        inds(j,1:length(find(a==j-1)))=find(a==j-1);  
        
    end
    inds_sec=inds;
    
    clear l_ofeach l_ofeachep 
    
    for j=1:5 % 5 if REM also exists; 4 if no REM
        
        x=unique(squeeze(inds_sec(j,:)));
        x(find(x==0))=[];
        if length(x)>1
            n=0;
            beg=1;
            ed=1;
            for k=2:length(x)
                if x(k)-x(k-1)>1|k==length(x)
                    n=n+1;
                    
                    if x(k)-x(k-1)>1
                        ed=k-1;
                    else
                        ed=k
                    end
                    l_ofeach(j,n,:)=[x(beg),x(ed)];
                    beg=k;
                end
            end
        end
    end
    %segment index to discontinuous parts.

    
    
    n=0;
    kn=size(l_ofeach,2);
    for j=1:size(l_ofeach,1)
        
        for k=1:kn
            
            if l_ofeach(j,k,2)-l_ofeach(j,k,1)+1>=ep_length/30;
                n=n+1;
                l_ofeachep(n,:)=[j,l_ofeach(j,k,1),l_ofeach(j,k,2)];
            end
        end
        
    end
    %find duration > 'episode length' and convert 4-D matrix to a 2-D matrix with stage(column 1), subject(column 2),begin and end time (colomn 3&4)
    l_ofeachep(:,5)=(l_ofeachep(:,3)-l_ofeachep(:,2)+1)/round(ep_length/30); 
    %column 5 (number  of episode length)
    
    stgs=l_ofeachep;
    % give a new, short name
    
    cd(root)
    cd('nii');
    
    stgs(:,6)=floor(stgs(:,5));
    if ~isempty(stgs)
        
        sleepfile=dir(['*',fmri_key,'*.nii*']);
        a_info=niftiinfo(sleepfile(file_n).name);
        if TR==0
        nifti_struc=nifti(sleepfile(file_n).name);
        if ~isfield(nifti_struc.timing,'tspace')
            error('No TR information');
        else
            TR = nifti_struc.timing.tspace;
        end
        end
        out_info = a_info;
        out_info.ImageSize(4) = round(ep_length/TR);
        a=niftiread(sleepfile(file_n).name);
        
        for i=1:size(stgs,1)
            cd(root)
            cd('nii')
      
            fir0=(stgs(i,2)-1)*round(30/TR)+10+1;
            %first volume
            num_dir=0;
            for j=1:stgs(i,6)
                cd([root,'/nii/']);
                dpabi_num=dpabi_num+1;
                temp=strfind(filenames,['stage',num2str(stgs(i,1)-1)]);
                num_dir=length(find(~cellfun(@isempty,temp)==1))+1;
                if dpabi_num==1
                    dirname = 'FunImg';
                else
                    dirname=['S',num2str(dpabi_num),'_FunImg'];
                end
                mkdir(dirname)
                cd(dirname)
                mkdir('s1');
                cd('s1');
                
                filename=['stage',num2str(stgs(i,1)-1),'sess',num2str(num_dir,'%02d')];
                
                filenames{dpabi_num}=filename;
                
                fir=fir0+round(ep_length/TR)*(j-1);
      
                out_info.Filename=[cd,'/',filename];
                niftiwrite(a(:,:,:,fir:fir+round(ep_length/TR)-1),filename,out_info);
            end
           
            cd(root)

        end
        
    end
    
end

cd(root)
cd('nii');

save('filenames.mat','filenames');
delete('filenames.txt');
h=fopen('filenames.txt','w');
for i=1:length(filenames)
    fprintf(h,[filenames{i},'\n']);
end
fclose(h);


mkdir('T1Img');
cd('T1Img');
mkdir('s1');
cd([root,'/nii'])
t1f=dir('*t1*');
for i=1:length(t1f)
    copyfile(t1f(i).name,[root,'/nii/T1Img/s1/']);
    copyfile(t1f(i).name,[root,'/nii/T1Img/s1/co',t1f(i).name]);
end
% move t1 file
quit()
