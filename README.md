# A-PASS

Setting up Python Dependencies
The recommended way is to set up a new conda environment using the requirement.yml file we provide. Alternatively, the user can choose to install all the packages using pip.

First clone/download our package into any directory you wish, then set up the dependencies via the following ways.

1. Using yml file (Recommended)
To set up the environment using the yml file, simply execute the following commands, and a new conda environment with name bcgnet_TF230

cd $PATH_TO_OUR_PACKAGE

conda env create -f requirement.yml
2. Using pip
Alternatively, the user can choose to install all the Python dependencies using pip via the following commands

cd $PATH_TO_OUR_PACKAGE

pip install requirement.txt
The user then needs to install jupyterlab and the detailed instructions can be found here.

Note: to check the TensorFlow version, execute

python -c 'import tensorflow as tf; print(tf.__version__)'
