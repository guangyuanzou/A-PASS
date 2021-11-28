tic
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
rmdir('stats','s');
mkdir('stats');
% %cd([subs(1).name,'/nii/Results']);
% %direcs=dir('*_*');
% 
% 
% paraname={};
% if Cfg.ALFF==1
%     paraname=[paraname,'ALFF','fALFF'];
% end
% if Cfg.ReHo==1
%     paraname=[paraname,'ReHo'];
% end
% if Cfg.DC == 1
%     paraname=[paraname,'DegreeCentrality'];
% end
% if Cfg.FC==1;
%     paraname=[paraname,'FC'];
% end
% if Cfg.VMHC==1;
%     paraname=[paraname,'VMHC'];
% end
%roinum=0;
% for i=1:length(direcs);
%     x=strsplit(direcs(i).name,'_');
%     if ~strcmp(x{1},'ROISignals')
%         rmdir(x{1},'s');
%         mkdir(x{1});
%         paraname=[paraname,x{1}];
%     end
% end
% 
% cd(root)
% cd('stats');
% load('paraname.mat');
% for i=1:length(paraname)
%     if exist(paraname{i},'dir')
%     rmdir(paraname{i},'s');
%     end
%     mkdir(paraname{i});
%     
% end
paraname={'ALFF','fALFF','ReHo','DegreeCentrality','FC','VMHC'};
is_eachsub=zeros(6,length(subs));
roinum=zeros(1,length(subs));

parfor i=1:length(subs)
   
        cd(root)
        cd(subs(i).name);
        
        cd('nii');
        filenames_m=dir('filenames.mat');
        if length(filenames_m)==1
            
            fn_st=load('filenames.mat');
            res_dir1=dir('*Results');
            [~,id]=sort_nat({res_dir1.name});
            res_dir = res_dir1(id);
            
            res_dirs1=dir('*ResultsS');
            [~,id]=sort_nat({res_dirs1.name});
            res_dirs = res_dirs1(id);
            
            cd('RealignParameter');
            exclude_f1=dir('*ExcludeSubject*');
            [~,id]=sort_nat({exclude_f1.name});
            exclude_f = exclude_f1(id);
            
            if length(res_dir)>0
                for j=1:length(res_dir)
                    cd(root)
                    cd(subs(i).name);
                    cd('nii')
                    
                    cd('RealignParameter');
                    dat = importdata(exclude_f(j).name);
                    if strcmp(dat{10,1},'None')
                        
                        
                        for k=1:length(paraname)
                            cd(root)
                            cd(subs(i).name);
                            cd('nii');
                            
                            if ismember(paraname(k),{'ALFF','fALFF','VMHC'})
                                cd(res_dir(j).name)
                                
                                dirn=dir([paraname{k},'_*']);
                                if length(dirn)==1
                                    is_eachsub(k,i)=1;
                                    zfile=[];
                                    cd(dirn.name)
                                    zfile=dir(['z*',paraname{k},'*.nii']);
                                    copyfile(zfile(end).name,[root,'/stats/',paraname{k},'/',fn_st.filenames{j}(1:6),...
                                        '_',subs(i).name,'_',fn_st.filenames{j}(7:end),'_',paraname{k},'.nii']);
                                elseif length(dirn)>1
                                    error('something wrong while moving results');
                                    
                                end
                            elseif strcmp(paraname{k},'FC')
                                cd(res_dir(j).name)
                                dirn = dir([paraname{k},'_*']);
                                if length(dirn)==1
                                    is_eachsub(k,i)=1;
                                    zfile=[];
                                    cd(dirn.name)
                                    zfile=dir(['z*',paraname{k},'*.nii']);
                                    %roinum=roinum+length(zfile);
                                    %roinum
                                    roinum(i)=length(zfile);
                                    if length(zfile)==1
                                        lab = strsplit(zfile(1).name,'Map')
                                        copyfile(zfile(1).name,[root,'/stats/',paraname{k},'/',lab{1},'ROI1_',fn_st.filenames{j}(1:6),...
                                            '_',subs(i).name,'_',fn_st.filenames{j}(7:end),'_',paraname{k},'.nii'])
                                    else
                                        for nz=1:length(zfile)
                                            lab = strsplit(zfile(nz).name,'Map')
                                            copyfile(zfile(nz).name,[root,'/stats/',paraname{k},'/',lab{1},'_',fn_st.filenames{j}(1:6),...
                                                '_',subs(i).name,'_',fn_st.filenames{j}(7:end),'_',paraname{k},'.nii'])
                                        end
                                    end
                                elseif length(dirn)>1
                                    error('something wrong while moving results');
                                end
                            else
                                cd(res_dirs(j).name)
                                dirn=dir([paraname{k},'_*']);
                                if length(dirn)==1
                                    is_eachsub(k,i)==1;
                                    zfile=[];
                                    cd(dirn.name)
                                    zfile=dir(['sz*',paraname{k},'*.nii']);
                                    copyfile(zfile(end).name,[root,'/stats/',paraname{k},'/',fn_st.filenames{j}(1:6),'_',subs(i).name,'_',fn_st.filenames{j}(7:end),'_',paraname{k},'.nii']);
                                elseif length(dirn)>1
                                    error('something wrong while moving results');
                                    
                                end
                                
                                cd ..
                                
                            end
                        end
                    end
                    
                end
            end
        
   
    end
end
cd(root)
cd stats
%roinum 
% if exist('roinum')
%     delete('roinum.txt');
%     froi = fopen('roinum.txt','w');
%     fprintf(froi,[num2str(roinum),'\n']);
%     fclose(froi);
% end
for i=1:length(subs)
    if length(unique(is_eachsub(:,i)))>1
        error(['Subject', num2str(i),' lacks some metrics']);
        quit()
    end
end

paraname_towrite = {};
for k=1:6
    if length(unique(is_eachsub(k,:)))~=1
        warning(['Subject ',num2str(is_eachsub(k,find(is_eachsub==0))),' lacks ',parameter{k}]);
        %quit()
    end
    if unique(is_eachsub(k,:))==1
        paraname_towrite=[paraname_towrite,paraname{k}];
    end
end
cd(root)
cd('stats');

save('paraname.mat','paraname_towrite');
delete('paraname.txt');
g=fopen('paraname.txt','w');
for i=1:length(paraname_towrite)
    fprintf(g,[paraname_towrite{i},'\n']);
end
fclose(g);

if length(unique(roinum))>2
    error(['Inconsisten ROI numbers across subjects: ',num2str(roinum)])
    quit()
end

delete('roinum.txt');
froi=fopen('roinum.txt','w');
fprintf(froi,num2str(max(roinum)));
fclose(froi)





cpfilename={};
cd(root)
rmdir('fwhmx','s');

mkdir('fwhmx');
parfor i=1:length(subs)
    try
    cd(root)
    cd(subs(i).name);
    cd('nii');
    fn_st=load('filenames.mat');
    smoothdir1=dir('*FunImgARCWS');
    [~,id]=sort_nat({smoothdir1.name});
    smoothdir=smoothdir1(id);
    cd('RealignParameter');
    exclude_f1=dir('*ExcludeSubject*');
    [~,id]=sort_nat({exclude_f1.name});
    exclude_f = exclude_f1(id);
    
    
    
    for j=1:length(smoothdir)
        
        cd(root)
        cd(subs(i).name);
        cd('nii')
        
        cd('RealignParameter');
        dat = importdata(exclude_f(j).name);
        if strcmp(dat{10,1},'None')
        cd(root)
        cd(subs(i).name);
        cd('nii'); 
        
        cd(smoothdir(j).name);
        cd('s1');
        sfile=[]
        sfile=dir('*.nii');
        copyfile(sfile.name,[root,'/fwhmx/',fn_st.filenames{j}(1:6),'_',subs(i).name,'_',fn_st.filenames{j}(7:end),'_',sfile.name])
        nameadd={[fn_st.filenames{j}(1:6),'_',subs(i).name,'_',fn_st.filenames{j}(7:end),'_',sfile.name]};
        cpfilename=[cpfilename,nameadd];
        cd ..
        cd ..
        end
    end
    end
end
cd(root)
cd('fwhmx')
delete('sfnames.txt');
h=fopen('sfnames.txt','w');
for i=1:length(cpfilename)
    fprintf(h,[cpfilename{i},'\n']);
end
fclose(h);
toc

quit;
