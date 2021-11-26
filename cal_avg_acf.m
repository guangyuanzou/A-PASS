% Written by ZOU Guangyuan, 2021.09.26
% Calculate the average of esimated parameters from 3dFWHMx (AFNI program).
% The parameters are used to derive the cluster size threshold for multiple
% correction.
%
% root: root path of working directory
cd(root);
d=dir('stage*txt');

for i=1:length(d)
    b{i}=d(i).name(1:12);
end

b=b';
c=unique(b);
for i=1:length(c)
    num(i)=length(find(strcmp(b,c(i))==1))
end

f=dir('stage*txt')
for i=1:length(f)
    t=dlmread(f(i).name);
    acf(i,:)=t(2,1:4);
end

num=num';
num(1,2)=1;
for i=2:length(c)
    num(i,2)=1+sum(num(1:i-1,1));
end
for i=1:length(c)
    if num(i,1)>1
        acf_average(i,:)=mean(acf(num(i,2):num(i,2)+num(i,1)-1,:));
    else
        acf_average(i,:)=acf(num(i,2),:);
    end
end

res=mean(acf_average);
f=fopen('acfpara.txt','w');
fprintf(f,num2str(res(1:3)));
fclose(f);
quit()