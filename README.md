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
3. Install AFNI according to the guide at https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/main_toc.html

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
