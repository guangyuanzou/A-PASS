# Written by ZOU Guangyuan 2021.09.26
# Subject-level processing of EEG-fMRI data in A-PASS
# apassdir: path of A-PASS
# rtpath: root path of data
# subs: string of subjects ID to be processed, e.g., 'sub01 sub02 sub03 sub06'
# mrc: whether to perform MR artifact correction, 1 for yes
# bcgc: whether to perform BCG artifact correction, 1 for yes
# ss: whether to perform automatic sleep scoring, 1 for yes
# checkss: whether to perform manual sleep scoring, 1 for yes
# dicsort: whether to perform dicom sorting, 1 for yes
# dicnii: whether to perform dicom-to-nifti convertion, 1 for yes.
# fmriproc: whether to perform fmri analysis, 1 for yes.
# pyenv: environment name if using conda, 'pyapass' is recommended
# conda_path: full path of conda.sh, e.g., '/disk1/anaconda3/etc/profile.d/conda.sh' 
while getopts a:b:c:d:e:f:g:h:i:j:k:l: opts;
do
  case $opts in
   a) apassdir=$OPTARG
      {
      echo $apassdir
      if [ "$apassdir" = "-b" ]
      then
         echo 'no A-PASS dir found'
         exit
      fi
      };;
      
   b) rtpath=$OPTARG
      {
      if [ "$rtpath" = '-c' ]
      then
         echo 'no directory found'
         exit 
      fi
      };;
   c) subs=$OPTARG
      {
      if [ "$subs" = '-d' ];then
         echo 'no subject found'
         exit
      fi
      };;

   d) mrc=$OPTARG;;
   e) bcgc=$OPTARG;;
   f) ss=$OPTARG;;
   g) checkss=$OPTARG;;
   h) dicsort=$OPTARG;;
   i) dicnii=$OPTARG;;
   j) fmripro=$OPTARG;;
   k) pyenv=$OPTARG;;
   l) conda_path=$OPTARG;;
  esac
done

echo $rtpath
echo $subs
echo $apassdir
echo $mrc,$bcgc,$ss,$checkss,$dicsort,$dicnii,$fmripro,$pyenv
cd ${rtpath}
# get variables from matlab A-PASS GUI-------------------------------------

tempfifo=${apassdir}/$$.fifo
#$echo $tempfifo
trap 'exec 913>&-;exec 913<&-;exit 0' 2
mkfifo $tempfifo
exec 913<>$tempfifo
rm -rf $tempfifo

for ((i=1; i<=5; i++))
do 
   echo >&913
done
# make fifo to control parallel task numbers (5 in paralell)---------------------


for sub_name in ${subs}
do
	read -u913	
        {
        work_dir=${rtpath}/${sub_name}
	cd ${work_dir}
	echo $(date +%R)
	dcmpath=${work_dir}/'dcm'
	cd ${work_dir}
	sortedpath=${work_dir}/'dcmsorted'
        if [ $dicsort = '1' ];then
            mkdir dcmsorted
	    cd ${dcmpath}
	    for each in `ls ${dcmpath} `
	      do
  	      seriesID=`dicom_hdr ${each} | grep "Series Number" | awk -F"//" '{print $3}'`;
  	      protocolname=`dicom_hdr ${each} | grep "Protocol Name" | awk -F"//" '{print $3}'`;
              acqdate=`dicom_hdr ${each} | grep "Series Date" | awk -F"//" '{print $3}'`;
  	      foldname=`echo ${acqdate}_${seriesID}_${protocolname} |sed 's/ //g'`
  	      if [ ! -e ${sortedpath}/${foldname} ]; then
  	        mkdir -p ${sortedpath}/${foldname};
  	        echo "Series ${seriesID}"
  	      fi;
  	      cp ${each} ${sortedpath}/${foldname};
	      done
        fi
        echo 'dicomsort done'        
        echo $(date +%R)
        #dicom sort (AFNI)-------------------------------
        if [ $dicnii = '1' ];then
           cd ${work_dir}
           rm -rf nii/
           mkdir nii
           cd ${sortedpath}
           echo ${sortedpath}
	   for each in `ls ${sortedpath}`
	   do
             #Dimon -infile_prefix ${sortedpath}/${each}/ -gert_create_dataset -gert_write_as_nifti -dicom_org
  	     #mv OutBrick* ${work_dir}/nii/${each}.nii
             dcm2niix_afni -o ${work_dir}/nii $each
	   done
        fi
	echo 'dicom2nii done'
        echo $(date +%R)
        #dicom2nii (AFNI)---------------------------------------
        cd ${work_dir}       
        if [ $mrc = '1' ];then
	   cd ${work_dir}
	   matlab -nodesktop -nosplash -r "root='$work_dir'",<${apassdir}/MRc.m
           
        fi
        echo 'MR artifact correction done'
        echo $(date +%R)
        #MR artifact correction (MATLAB:EEGLAB)--------------------------------

	cd ${work_dir}
	if [ $pyenv != 'default' ];then
            #echo 'a'
            conpath=`grep '\.\ .*conda\.sh' ~/.bashrc`
            eval $conpath
            pya=`conda info -e | grep pyapass`
            if [ -n "$pya" ];then
            #source ${conda_path}
            conda activate ${pyenv}
            fi
        fi
        #conda activate------------------------------------------------
        if [ $bcgc = '1' ];then
            cd ${apassdir}/toolboxes/BCGNet-master
	    python ${apassdir}/toolboxes/BCGNet-master/BCGc.py ${work_dir} ${sub_name} 
        fi
        echo 'ECG artifact correction done'
        echo $(date +%R)
        #BCG artifact correction (Python:BCGnet)----------------------------------------

	cd ${work_dir}
        if [ $ss = '1' ];then
                 cd ${apassdir}/toolboxes/vit-pytorch-main/vit_pytorch
	         python ./vitcrf_pred.py ${work_dir}/'cleaned_EEGdata'/${sub_name}
        fi
        #Automatic scoring (Python:Vit-CRF)------------------------------------------------
	cd ..
        echo $checkss
        if [ $checkss = '1' ];then
           
           cleanedEEGpath=${work_dir}/cleaned_EEGdata/${sub_name}
           cd ${cleanedEEGpath}
           matlab -nodesktop -nosplash -r "root='${cleanedEEGpath}',apassdir='$apassdir'", <${apassdir}/manual_check.m &
           wait
        fi
        #manual checking of scores (MATLAB)----------------------------------------------
        echo 'sleep stage scoring done'
        echo $(date +%R)

        if [ $fmripro = '1' ];then
	   matlab -nodesktop -nosplash -r "root='$work_dir',apassdir='$apassdir',sub_name='$sub_name'",<${apassdir}/fmriseg.m         
           #segment fmri to episodes (MATLAB)----------------------------------- 
	   cd ${work_dir}
           matlab -nodesktop -nosplash -r "root='$work_dir',apassdir='${apassdir}'",<${apassdir}/fmri_proc.m
           #fmri preprocessing (MATLAB:DPARSF)----------------------------
        fi 
        echo 'Subject processing finished'
	echo $(date +%R)
	echo >&913
        } > ${rtpath}/${sub_name}/diary_${sub_name}.txt 2>&1 &
        
        #processing of each subject recorded in a diary file
done
wait
echo 'All subjects processing finished'

