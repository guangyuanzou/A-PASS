# A-PASS
A robust pipeline to automatically process and analyze simultaneously acquired EEG-fMRI data for sleep research
## Installation
1. Download the master branch.
2. Set up Python environment.
  The recommended way is to set up a new conda environment using the apass_requirement.yaml file
  ```
  conda env create -f apass_requirement.yaml
  ```
  Alternatively, users can install all the packages using pip
  ```
  pip install req.txt
  ```

## Data arrangement

```
Working dirctory  
  |-sub1  
  |   -subject1_sleep1.eeg  
  |   -subject1_sleep1.vhdr  
  |   -subject1_sleep1.vmrk  
  |   -subject1_sleep2.eeg  
  |   -subject1_sleep2.vhdr  
  |   -subject1_sleep2.vmrk  
  |   ...  
  |   -subject1_sleepN.eeg  
  |   -subject1_sleepN.vhdr  
  |   -subject1_sleepN.vmrk 
  |   -dcmsorted  
  |      -T1  
  |      -Sleep1  
  |        -xxx.dcm  
  |        ...  
  |      -Sleep2  
  |      ...  
  |      -SleepN
  |-sub2  
  |...   
  |-subN  
  |coviartes.xlsx (if applicable)  
```
