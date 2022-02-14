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
Alternatively, the user can choose to install all the Python dependencies using pip via the following commands

cd $PATH_TO_OUR_PACKAGE

pip install requirement.txt
The user then needs to install jupyterlab and the detailed instructions can be found here.

Note: to check the TensorFlow version, execute

python -c 'import tensorflow as tf; print(tf.__version__)'

Data arrangement

Working dirctory 
  |-sub1  
  |   -subject1_sleep1.eeg
  |   -subject1_sleep1.vhdr
  |   -subject1_sleep1.vmrk
  |   -subject1_sleep2.eeg
  |   -subject1_sleep2.vhdr
  |   -subject1_sleep2.vmrk
  |   ...
  |   -dcmsorted
  |      -T1
  |      -Sleep1
  |        -xxx.dcm
  |        ...
  |      -Sleep2
  |      ...
  |-sub2
  |...
  |-subN
  |coviartes.xlsx (if applicable)
