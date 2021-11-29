# Written by ZOU Guangyuan 2021.09.26, part of A-PASS
# Statistical analysis of EEG-fMRI data for sleep research
# apassdir: path of A-PASS
# rtpath: root path of data
# subs: string of subjects ID to be processed, e.g., 'sub01 sub02 sub04 sub06' 
while getopts a:r:s: opts;
do
  case $opts in
   a) apassdir=$OPTARG
      {
      if [ "$apassdir" == "-r" ]
      then
         echo 'no A-PASS dir found'
         exit
      fi
      };;
   r) rtpath=$OPTARG
      {
      if [ "$rtpath" == "-s" ]
      then
         echo 'no directory found'
         exit 
      fi
      };;
   s) subs=$OPTARG
      {
      if [ "$subs" == "-m" ];then
         echo 'no subject found'
         exit
      fi
      };;
#   ?) ;;
  esac
done
# get variables from matlab A-PASS GUI-------------------------------------
{
cd ${rtpath}
matlab -nodesktop -nosplash -r "root='${rtpath}',apassdir='${apassdir}'",<${apassdir}/moveres.m
echo $(date +%R)
# moving processed fmri files to stat folder-------------------------------------------
matlab -nodesktop -nosplash -r "root='${rtpath}',apassdir='${apassdir}'",<${apassdir}/preparetxt.m
# 3dLMEr model building -------------------------------------------------------------
roinum=1
echo $(date +%R)
cd ${rtpath}/stats

tempfifo=${apassdir}/$$.fifo
trap 'exec 914>&-;exec 914<&-;exit 0' 2
mkfifo $tempfifo
exec 914<>$tempfifo
rm -rf $tempfifo


for ((i=1; i<=8; i++))
do 
   echo >&914
done



for line in `cat paraname.txt`
do
 {
 cd $line
 if [ "$line" == "FC" ]
 then
   cd ..
   roinum=`cat roinum.txt`
   cd $line
   for ((i=1; i<=${roinum}; i++))
   do
    {
     read -u914
     tcsh -x 3dlmert_roi$i.txt > diary_${line}_roi$i.txt 
     echo >& 914
    } &
   done
 else
   {
   read -u914
   tcsh -x 3dlmert.txt > diary_${line}.txt
   echo >& 914
   } &
 fi
 cd ..
 }
done
wait
echo $(date +%R)
# 3dLMEr analysis (AFNI)----------------------------------------------------------

#tempfifo=$$.fifo
#$echo $tempfifo


cd ${rtpath}/fwhmx
for line in `cat sfnames.txt`
do
 { 
 read -u914
 rm -f 3dFWHMx.1D
 rm -f 3dFWHMx.1D*
 rm -f ${line}.txt
 3dFWHMx -input ${rtpath}/fwhmx/${line} -unif -acf ${line}.1D -arith -detrend -mask ${apassdir}/MNI152mask.nii > ${line}.txt
 echo >& 914
 }&
done

wait

echo 'done'
#smooth estimation (AFNI)--------------------------------------------------------------

matlab -nodesktop -nosplash -r "root='${rtpath}/fwhmx'",<${apassdir}/cal_avg_acf.m

cd ${rtpath}
cd 'fwhmx'
3dClustSim -mask ${apassdir}/MNI152mask.nii -acf `cat acfpara.txt` -athr 0.1 0.05 0.02 0.01 0.001 -prefix 3dClustSim_acf.txt
#Simulating cluster size for multiple testing correction (AFNI)-----------------------------
echo $(date +%R)

}  > ${rtpath}/diary_stats.txt 2>&1
echo $(date +%R)
