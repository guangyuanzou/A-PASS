% Written by ZOU Guangyuan
% Prepare 3dLMEr text files to perform linear mixed modeling in A-PASS
% See program 3dLMEr of AFNI for detail
% root: root path of working directory
% apassdir: path of A-PASS
cd(root)
cov_num = 0;
xlsfile=dir('covariates.xlsx');
if length(xlsfile)~=0
    [a b cpar]=xlsread('covariates.xlsx');
end
% Read covariates file if exists
tablehead=' subject session condition ';
model_=[" -model 'condition"];
model='';

if exist('cpar')
    if strcmp(cpar{1,2},'group')
        cov_num = shape(cpar,2)-2;
        tablehead=' subject session condition group ';
        model_ = [" -model 'condition*group"];
        groups=unique(cpar(2:end,2));
    else
        cov_num = shape(cpar,2)-1;
    end
    qVars_=" -qVars '";
    qVars='';
    conv_n=size(cpar,2)-1;
    for i=1:conv_n
        tablehead=[tablehead,' ',cpar{1,i+1}];
        model_=[model_,'+',cpar{1,i+1}];
        if strcmp(class(cpar{2,i+1}),'double')
            qVars_=[qVars_,cpar{1,i+1},','];
        end
    end
    qVars_=[qVars_(1:end-1),"' \\\n"];
    
    for i=1:length(qVars_)
        qVars=strcat(qVars,qVars_(i));
    end
    
end

tablehead=[tablehead,' InputFile \\\n'];
model_=[model_,"+(1|subject)+(1|session)' \\\n"];



for i=1:length(model_)
    model=strcat(model,model_(i));
end
cd('stats');
delete('cov_num.txt')
f_cov = fopen('cov_num.txt','w');
fprintf(f_cov,num2str(cov_num));
fclose(f_cov)
load('paraname.mat');
if exist('cpar')&strcmp(cpar{1,2},'group')
    for i=1:length(paraname)
        if strcmp(paraname{i},'FC')
            cd(paraname{i})
            roifiles=dir('*ROI*.nii');
            roinum = load([root,'/stats/roinum.txt']);
            for j=1:roinum
                delete(['3dlmert_roi',num2str(j),'.txt']);
                f=fopen(['3dlmert_roi',num2str(j),'.txt'],'w');
                fprintf(f,['3dLMEr -prefix lmer_',paraname{i},'ROI',num2str(j),'.nii -jobs 16 \\\n'])
                fprintf(f,[' -mask ',apassdir,'/MNI152mask.nii \\\n']);
                %fprintf(f,[" -model 'condition+age+edu+sex+(1|subject)+(1|session)' \\\n"]);
                fprintf(f,[model]);
                %fprintf(f,[" -qVars 'age,edu' \\\n"]);
                if exist('qVars')
                    fprintf(f,qVars);%stage_name = unique(stages_all);;
                end
                files=dir(['*ROI',num2str(j),'*.nii']);
                if ~exist('stage_name')
                    for na=1:length(files)
                        name_sp = strsplit(files(na).name,'_');
                        stages_all{na}=name_sp{2};
                        subs_all{na,1}=name_sp{3};
                        subs_all{na,2} = cpar{find(strcmp(cpar(:,1),name_sp{3})),2};
                    end
                    stage_uni = unique(stages_all);
                    stage_name={};
                    %clear file_num;
                    for item=1:length(stage_uni)
                        c_stageid = find(strcmp(stages_all,stage_uni{item}));
                        c_stage_groups = subs_all{c_stageid,2};
                        for gtem = 1:length(groups);
                            file_num(item,gtem) = length(find(strcmp(c_stage_groups,groups{item})));
                        end
                        
                        
                    end
                    for item=1:length(stage_uni)
                        if min(item,:)>0
                            stage_name = [stage_name,stage_uni{item}];
                        end
                    end
                end
                
                fprintf(f,[' -dataTable \\\n']);
                fprintf(f,[tablehead]);
                
                for k=1:length(files)
                    table_cont=strsplit(files(k).name,'_');
                    if ismember(table_cont{2},stages_name);
                        line=[table_cont{3},' ',table_cont{4},' ',table_cont{2},' '];
                        if exist('cpar')
                            id=find(strcmp(cpar(:,1),table_cont{2})==1);
                            for m=1:conv_n
                                line=[line,' ',num2str(cpar{id,m+1})];
                            end
                        end
                        
                        line=[line,' ',files(k).name,' \\\n'];
                        fprintf(f,line);
                    end
                end
                fclose(f);
                
                
            end
            
        else
            cd(paraname{i})
            delete('3dlmert.txt');
            f=fopen('3dlmert.txt','w');
            fprintf(f,['3dLMEr -prefix lmer_',paraname{i},'.nii -jobs 16 \\\n'])
            fprintf(f,[' -mask ',apassdir,'/MNI152mask.nii \\\n']);
            %fprintf(f,[" -model 'condition+age+edu+sex+(1|subject)+(1|session)' \\\n"]);
            fprintf(f,[model]);
            %fprintf(f,[" -qVars 'age,edu' \\\n"]);
            if exist('qVars')
                fprintf(f,qVars);
            end
            files=dir('*.nii');
            if ~exist('stage_name')
                for na=1:length(files)
                    name_sp = strsplit(files(na).name,'_');
                    stages_all{na}=name_sp{1};
                    subs_all{na,1}=name_sp{2};
                    subs_all{na,2}=cpar{find(strcmp(cpar(:,1),name_sp{2})),2};
                end
                stage_uni = unique(stages_all)
                stage_name={};
                for item=1:length(stage_uni)
                    c_stageid = find(strcmp(stages_all,stage_uni{item}));
                    c_stage_groups = subs_all{c_stageid,2};
                    for gtem = 1:length(groups);
                        file_num(item,gtem) = length(find(strcmp(c_stage_groups,groups{item})));
                    end
                    
                    
                end
                for item=1:length(stage_uni)
                    if min(item,:)>0
                        stage_name = [stage_name,stage_uni{item}];
                    end
                end
                
            end
            
            fprintf(f,[' -dataTable \\\n']);
            fprintf(f,[tablehead]);
            
            for j=1:length(files)
                table_cont=strsplit(files(j).name,'_');
                if ismember(table_cont{1},stages_name)
                    line=[table_cont{2},' ',table_cont{3},' ',table_cont{1},' '];
                    
                    if exist('cpar')
                        id=find(strcmp(cpar(:,1),table_cont{2})==1);
                        for k=1:conv_n
                            line=[line,' ',num2str(cpar{id,k+1})];
                        end
                    end
                    line=[line,' ',files(j).name,' \\\n'];
                    fprintf(f,line);
                end
            end
            fclose(f);
        end
        cd ..
    end
else
    for i=1:length(paraname)
        if strcmp(paraname{i},'FC')
            cd(paraname{i})
            roifiles=dir('*ROI*.nii');
          
            roinum = load([root,'/stats/roinum.txt']);
            for j=1:roinum
                delete(['3dlmert_roi',num2str(j),'.txt']);
                f=fopen(['3dlmert_roi',num2str(j),'.txt'],'w');
                fprintf(f,['3dLMEr -prefix lmer_',paraname{i},'ROI',num2str(j),'.nii -jobs 16 \\\n'])
                fprintf(f,[' -mask ',apassdir,'/MNI152mask.nii \\\n']);
                %fprintf(f,[" -model 'condition+age+edu+sex+(1|subject)+(1|session)' \\\n"]);
                fprintf(f,[model]);
                %fprintf(f,[" -qVars 'age,edu' \\\n"]);
                if exist('qVars')
                    fprintf(f,qVars);%stage_name = unique(stages_all);;
                end
                files=dir(['*ROI',num2str(j),'*.nii']);
                if ~exist('stage_name')
                    for na=1:length(files)
                        name_sp = strsplit(files(na).name,'_');
                        stages_all{na}=name_sp{2};
                    end
                    stage_uni = unique(stages_all);
                    stage_name={};
                    for item=1:length(stage_uni)
                        if length(find(stage_uni{item})==1)>=3
                            stage_name = [stage_name,stage_uni{item}];
                        end
                    end
                end
                if ismember('stage0',stage_name)&ismember('stage1',stage_name)
                    fprintf(f,[" -gltCode w-n1 'condition : 1*stage0 -1*stage1' \\\n"]);
                end
                if ismember('stage0',stage_name)&ismember('stage2',stage_name)
                    fprintf(f,[" -gltCode w-n2 'condition : 1*stage0 -1*stage2' \\\n"]);
                end
                if ismember('stage0',stage_name)&ismember('stage3',stage_name)
                    fprintf(f,[" -gltCode w-n3 'condition : 1*stage0 -1*stage3' \\\n"]);
                end
                if ismember('stage1',stage_name)&ismember('stage2',stage_name)
                    fprintf(f,[" -gltCode n1-n2 'condition : 1*stage1 -1*stage2' \\\n"]);
                end
                if ismember('stage1',stage_name)&ismember('stage3',stage_name)
                    fprintf(f,[" -gltCode n1-n3 'condition : 1*stage1 -1*stage3' \\\n"]);
                end
                if ismember('stage2',stage_name)&ismember('stage3',stage_name)
                    fprintf(f,[" -gltCode n2-n3 'condition : 1*stage2 -1*stage3' \\\n"]);
                end
                if ismember('stage0',stage_name)&ismember('stage4',stage_name)
                    fprintf(f,[" -gltCode w-rem 'condition : 1*stage0 -1*stage4' \\\n"]);
                end
                if ismember('stage1',stage_name)&ismember('stage4',stage_name)
                    fprintf(f,[" -gltCode n1-rem 'condition : 1*stage1 -1*stage4' \\\n"]);
                end
                
                if ismember('stage2',stage_name)&ismember('stage4',stage_name)
                    fprintf(f,[" -gltCode n2-rem 'condition : 1*stage2 -1*stage4' \\\n"]);
                end
                if ismember('stage3',stage_name)&ismember('stage4',stage_name)
                    fprintf(f,[" -gltCode n3-rem 'condition : 1*stage3 -1*stage4' \\\n"]);
                end
                
                fprintf(f,[' -dataTable \\\n']);
                fprintf(f,[tablehead]);
                
                for k=1:length(files)
                    table_cont=strsplit(files(k).name,'_');
                    line=[table_cont{3},' ',table_cont{4},' ',table_cont{2},' '];
                    if exist('cpar')
                        id=find(strcmp(cpar(:,1),table_cont{2})==1);
                        for m=1:conv_n
                            line=[line,' ',num2str(cpar{id,m+1})];
                        end
                    end
                    line=[line,' ',files(k).name,' \\\n'];
                    fprintf(f,line);
                end
                fclose(f);
                
                
            end
        else
            cd(paraname{i})
            delete('3dlmer.txt');
            f=fopen('3dlmert.txt','w');
            fprintf(f,['3dLMEr -prefix lmer_',paraname{i},'.nii -jobs 16 \\\n'])
            fprintf(f,[' -mask ',apassdir,'/MNI152mask.nii \\\n']);
            %fprintf(f,[" -model 'condition+age+edu+sex+(1|subject)+(1|session)' \\\n"]);
            fprintf(f,[model]);
            %fprintf(f,[" -qVars 'age,edu' \\\n"]);
            if exist('qVars')
                fprintf(f,qVars);
            end
            files=dir('*.nii');
            if ~exist('stage_name')
                for na=1:length(files)
                    name_sp = strsplit(files(na).name,'_');
                    stages_all{na}=name_sp{1};
                end
                stage_uni = unique(stages_all)
                stage_name={};
                for item=1:length(stage_uni)
                    if length(find(stage_uni{item})==1)>=3
                        stage_name = [stage_name,stage_uni{item}];
                    end
                end
            end
            
            
            if ismember('stage0',stage_name)&ismember('stage1',stage_name)
                fprintf(f,[" -gltCode w-n1 'condition : 1*stage0 -1*stage1' \\\n"]);
            end
            if ismember('stage0',stage_name)&ismember('stage2',stage_name)
                fprintf(f,[" -gltCode w-n2 'condition : 1*stage0 -1*stage2' \\\n"]);
            end
            if ismember('stage0',stage_name)&ismember('stage3',stage_name)
                fprintf(f,[" -gltCode w-n3 'condition : 1*stage0 -1*stage3' \\\n"]);
            end
            if ismember('stage1',stage_name)&ismember('stage2',stage_name)
                fprintf(f,[" -gltCode n1-n2 'condition : 1*stage1 -1*stage2' \\\n"]);
            end
            if ismember('stage1',stage_name)&ismember('stage3',stage_name)
                fprintf(f,[" -gltCode n1-n3 'condition : 1*stage1 -1*stage3' \\\n"]);
            end
            if ismember('stage2',stage_name)&ismember('stage3',stage_name)
                fprintf(f,[" -gltCode n2-n3 'condition : 1*stage2 -1*stage3' \\\n"]);
            end
            if ismember('stage0',stage_name)&ismember('stage4',stage_name)
                fprintf(f,[" -gltCode w-rem 'condition : 1*stage0 -1*stage4' \\\n"]);
            end
            if ismember('stage1',stage_name)&ismember('stage4',stage_name)
                fprintf(f,[" -gltCode n1-rem 'condition : 1*stage1 -1*stage4' \\\n"]);
            end
            if ismember('stage2',stage_name)&ismember('stage4',stage_name)
                fprintf(f,[" -gltCode n2-rem 'condition : 1*stage2 -1*stage4' \\\n"]);
            end
            if ismember('stage3',stage_name)&ismember('stage4',stage_name)
                fprintf(f,[" -gltCode n3-rem 'condition : 1*stage3 -1*stage4' \\\n"]);
            end
            
            fprintf(f,[' -dataTable \\\n']);
            fprintf(f,[tablehead]);
            
            for j=1:length(files)
                table_cont=strsplit(files(j).name,'_');
                line=[table_cont{2},' ',table_cont{3},' ',table_cont{1},' '];
                if exist('cpar')
                    id=find(strcmp(cpar(:,1),table_cont{2})==1);
                    for k=1:conv_n
                        line=[line,' ',num2str(cpar{id,k+1})];
                    end
                end
                line=[line,' ',files(j).name,' \\\n'];
                fprintf(f,line);
            end
            fclose(f);
        end
        cd ..
    end
end

if exist('groups')
cd(root)
cd('stats')
delete('groupnum.txt');
f=fopen('groupnum.txt','w');
fprintf(num2str(length(groups)));
fclose(f);
end
%quit()

