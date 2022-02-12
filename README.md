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

|-config
|   __init__
|   default_config.yaml
|   load_config
|-dataset
|   __init__
|   dataset_utils
|   default_dataset
|-example_data
|-models
|   __init__
|   default_models
|   gru_arch_000
|   model_utils
|-session
|   __init__
|   data_generator
|   default_session
|-utils
|   __init__
|   context_management
|-.gitignore
|-__init__
|-demo.ipynb
|-README.md
|-requirement.txt
|-requirement.yml
2:31 PM 2/10/20223:40 PM 2/10/2022
