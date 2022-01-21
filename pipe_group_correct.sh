# Written by ZOU Guangyuan 2021.09.26, part of A-PASS
# Generate multiple corrected statistical maps
# rtpath: root path of data
while getopts r: opts;
do
  case $opts in

   r) rtpath=$OPTARG
      if [ "$rtpath" == -s ];then
         echo 'no directory found'
         exit 
      fi;;
#   ?) ;;
  esac
done
{
cd $rtpath
p1=`sed -n '1,1p' pval.txt`
p2=`sed -n '2,1p' pval.txt`
if [ "$p1" == "0.001" ];then
    volp="0\.00100"
elif [ "$p1" == "0.01" ];then
    volp="0\.010000"
elif [ "$p1" == "0.05" ];then
    volp="0\.050000"
fi
cd fwhmx
if  [ "$p2" == "0.05" ];then 
    clustersize=` grep $volp 3dClustSim_acf.txt.NN2_1sided.1D | awk -F " " '{print $3}'`
elif [ "$p2" == "0.01" ];then
    clustersize=` grep $volp 3dClustSim_acf.txt.NN2_1sided.1D | awk -F " " '{print $5}'`
elif [ "$p2" == "0.001" ];then
    clustersize=` grep $volp 3dClustSim_acf.txt.NN2_1sided.1D | awk -F " " '{print $6}'`
fi

#clustersize=` grep $volp 3dClustSim_acf.txt.NN2_2sided.1D | awk -F " " '{print $3}'`
echo $clustersize > clustersize.txt
echo $clustersize
# get cluster size for correction ---------------------------------------------------------------



cd ${rtpath}/stats
if [ ! -d resultnii ];then
mkdir resultnii
fi
resultdir=${rtpath}/stats/resultnii

roinum=`cat roinum.txt`
cov_num=`cat cov_num.txt`
if [ -f "groupnum.txt" ]
then
group_num=`cat groupnum.txt`
else
group_num=1
fi
#read parameters ------------------------------------------------------------------------------

if [ $group_num = 1 ]
then
#-----------processing for one group-----------------------------------------------------
for line in `cat paraname.txt`
do 
 echo $line
 cd ${rtpath}/stats
 cd $line
 if [ "$line" == "FC" ]
 then
    for i in `seq $roinum`
    do
    {
    3dmerge -1thresh 13.816 -1tindex 0 -1dindex 0 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}ROI${i}correctp_main.nii "lmer_${line}ROI${i}.nii"
    3dmerge -1thresh 0 -1tindex 0 -1dindex 0 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}ROI${i}unthr_main.nii "lmer_${line}ROI${i}.nii"
    cp -f lmer_${line}ROI${i}.nii ${resultdir}/lmer_${line}ROI${i}_auto.nii
    cp -f ${line}ROI${i}correctp_main.nii ${resultdir}/${line}ROI${i}correctp_main_auto.nii
    cp -f ${line}ROI${i}unthr_main.nii ${resultdir}/${line}ROI${i}unthr_main_auto.nii
   contrast=0
   for item in `grep 'gltCode' 3dlmert_roi${i}.txt | awk -F " " '{print $2}'`
   do 
    contrast=$(($contrast+1))
    3dmerge -1thresh 3.291 -1tindex $(($cov_num+2*$contrast)) -1dindex $(($cov_num+2*$contrast)) -dxyz=1 -1clust 1.5 ${clustersize}  -prefix ${line}ROI${i}correctp_${item}.nii "lmer_${line}ROI${i}.nii"
    3dmerge -1thresh 0 -1tindex $(($cov_num+2*$contrast)) -1dindex $(($cov_num+2*$contrast)) -dxyz=1 -1clust 1.5 ${clustersize}  -prefix ${line}ROI${i}unthr_${item}.nii "lmer_${line}ROI${i}.nii"
    cp -f ${line}ROI${i}correctp_${item}.nii ${resultdir}/${line}ROI${i}correctp_${item}_auto.nii 
    cp -f ${line}ROI${i}unthr_${item}.nii ${resultdir}/${line}ROI${i}unthr_${item}_auto.nii
    done
    
    
    } 
    done

 else
 
 3dmerge -1thresh 13.816 -1tindex 0 -1dindex 0 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}correctp_main.nii "lmer_${line}.nii"
 3dmerge -1thresh 0 -1tindex 0 -1dindex 0 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}unthr_main.nii "lmer_${line}.nii"

 cp -f lmer_${line}.nii ${resultdir}/lmer_${line}_auto.nii
 cp -f ${line}correctp_main.nii ${resultdir}/${line}correctp_main_auto.nii
 cp -f ${line}unthr_main.nii ${resultdir}/${line}unthr_main_auto.nii
contrast=0
      for item in `grep 'gltCode' 3dlmert.txt | awk -F " " '{print $2}'`
      do
      contrast=$(($contrast+1))
      3dmerge -1thresh 3.291 -1tindex $(($cov_num+2*$contrast)) -1dindex $(($cov_num+2*$contrast)) -dxyz=1 -1clust 1.5 ${clustersize}  -prefix ${line}correctp_${item}.nii "lmer_${line}.nii"
      3dmerge -1thresh 0 -1tindex $(($cov_num+2*$contrast)) -1dindex $(($cov_num+2*$contrast)) -dxyz=1 -1clust 1.5 ${clustersize}  -prefix ${line}unthr_${item}.nii "lmer_${line}.nii"
      cp -f ${line}correctp_${item}.nii ${resultdir}/${line}correctp_${item}_auto.nii
      cp -f ${line}unthr_${item}.nii ${resultdir}/${line}unthr_${item}_auto.nii
      done
 fi
 cd ..
done

else
#----------processing for multiple groups------------------------------------------
for line in `cat paraname.txt`
do 
 echo $line
 cd ${rtpath}/stats
 cd $line
 if [ "$line" == "FC" ]
 then
    for i in `seq $roinum`
    do
    {
    3dmerge -1thresh 13.816 -1tindex 0 -1dindex 0 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}ROI${i}correctp_inter.nii "lmer_${line}ROI${i}.nii"
    3dmerge -1thresh 0 -1tindex 0 -1dindex 0 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}ROI${i}unthr_inter.nii "lmer_${line}ROI${i}.nii"
    3dmerge -1thresh 13.816 -1tindex 1 -1dindex 1 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}ROI${i}correctp_condition.nii "lmer_${line}ROI${i}.nii"
    3dmerge -1thresh 0 -1tindex 1 -1dindex 1 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}ROI${i}unthr_condition.nii "lmer_${line}ROI${i}.nii"
    3dmerge -1thresh 13.816 -1tindex 2 -1dindex 2 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}ROI${i}correctp_group.nii "lmer_${line}ROI${i}.nii"
    3dmerge -1thresh 0 -1tindex 2 -1dindex 2 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}ROI${i}unthr_group.nii "lmer_${line}ROI${i}.nii"
    cp -f lmer_${line}ROI${i}.nii ${resultdir}/lmer_${line}ROI${i}_auto.nii
    cp -f ${line}ROI${i}correctp_inter.nii ${resultdir}/${line}ROI${i}correctp_inter_auto.nii
    cp -f ${line}ROI${i}unthr_inter.nii ${resultdir}/${line}ROI${i}unthr_inter_auto.nii
    cp -f ${line}ROI${i}correctp_condition.nii ${resultdir}/${line}ROI${i}correctp_condition_auto.nii
    cp -f ${line}ROI${i}unthr_condition.nii ${resultdir}/${line}ROI${i}unthr_condition_auto.nii
    cp -f ${line}ROI${i}correctp_group.nii ${resultdir}/${line}ROI${i}correctp_group_auto.nii
    cp -f ${line}ROI${i}unthr_group.nii ${resultdir}/${line}ROI${i}unthr_group_auto.nii
    
    } 
    done

 else
 
 3dmerge -1thresh 13.816 -1tindex 0 -1dindex 0 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}correctp_inter.nii "lmer_${line}.nii"
 3dmerge -1thresh 0 -1tindex 0 -1dindex 0 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}unthr_inter.nii "lmer_${line}.nii"
 3dmerge -1thresh 13.816 -1tindex 1 -1dindex 1 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}correctp_condition.nii "lmer_${line}.nii"
 3dmerge -1thresh 0 -1tindex 1 -1dindex 1 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}unthr_condition.nii "lmer_${line}.nii"
 3dmerge -1thresh 13.816 -1tindex 2 -1dindex 2 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}correctp_group.nii "lmer_${line}.nii"
 3dmerge -1thresh 0 -1tindex 2 -1dindex 2 -dxyz=1 -1clust 1.5 ${clustersize} -prefix ${line}unthr_group.nii "lmer_${line}.nii"
 cp -f lmer_${line}.nii ${resultdir}/lmer_${line}_auto.nii
 cp -f ${line}correctp_inter.nii ${resultdir}/${line}correctp_inter_auto.nii
 cp -f ${line}unthr_inter.nii ${resultdir}/${line}unthr_inter_auto.nii
 cp -f ${line}correctp_condition.nii ${resultdir}/${line}correctp_condition_auto.nii
 cp -f ${line}unthr_condition.nii ${resultdir}/${line}unthr_condition_auto.nii
 cp -f ${line}correctp_group.nii ${resultdir}/${line}correctp_group_auto.nii
 cp -f ${line}unthr_group.nii ${resultdir}/${line}unthr_group_auto.nii

 fi
 cd ..
done

fi
# Extract corrected results (AFNI) ---------------------------------------------------------
echo $(date +%R)
} > ${rtpath}/stats/diary_correct.txt 2>&1
