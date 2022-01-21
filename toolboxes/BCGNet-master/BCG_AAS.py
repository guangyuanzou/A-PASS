# -*- coding: utf-8 -*-
"""
Created on Thu Jul 15 18:08:02 2021
  
@author: ZOU Guangyuan
To perform BCG artifact correction in A-PASS

Adopting BCGNet
Reference:
BCGNet: Deep Learning Toolbox for BCG Artifact Reduction
========================================================
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![License](https://img.shields.io/github/license/SASVDERDBGTYS/BCGNet)](https://opensource.org/licenses/MIT)
[![doi](https://img.shields.io/badge/doi-10.1109%2FTBME.2020.3004548-blue)](https://ieeexplore.ieee.org/document/9124646)

see APASS/toolboxes/BCGNet-master/README.md for detail

"""
import sys
#BCGnetpath = sys.argv[0]
work_dir = sys.argv[1]
subs = [sys.argv[2]]
#print(subs)
import os
BCGnetpath = os.getcwd()
import time
from pathlib import Path
from config import get_config
from session import Session
import mne.io
import glob

work_dir = Path(work_dir)
BCGnetpath = Path(BCGnetpath)
print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()))

  
cfg = get_config(BCGnetpath / 'config' / 'default_config_pred.yaml')
# whether load pretrained weights is determined in config as cfg.p_model_weights
cfg.d_data = work_dir / 'MRcEEGdata'
cfg.d_model = work_dir / 'trained_models'
cfg.d_output = work_dir / 'cleaned_EEGdata'

cfg.d_eval = work_dir / 'AAS_cleaned_data'
cfg.str_eval = 'AAS'
#cfg.num_epochs = 50
cfg.d_root = BCGnetpath
d_root = cfg.d_root
#cfg.p_model_weights = d_root / 'default_weights' / 'default_rnn_model_20210719_214617'
cfg.p_model_weights = ''
# The model_weights was trained on EEG data from EEG-fMRI recordings of 31 subjects

for sub in subs:
  str_sub = sub
  if not os.path.exists(cfg.d_data /'figure'):
    os.mkdir(cfg.d_data / 'figure')
  # provide the name of the subject
  # provide the index of the runs to be used for training
  # if just a single run, then [1] or [2]
  # if multiple runs then [1, 2]
  
  # for a run from sub11 and run index 1
  # filename is presumed to be
  # subXX_r0X_
  set_files = glob.glob(cfg.d_data.as_posix()+'/'+str_sub+'/'+str_sub+'*_raw.set')
  vec_idx_run = [x+1 for x in range(len(set_files))] 
  data_len = 0;
  for file in set_files:
     raw = mne.io.read_raw_eeglab(file)
     #raw = mne.io.read_raw_eeglab(cfg.d_data.as_posix()+'/'+str_sub+'/'+str_sub+'_r0'+ str(vec_idx_run[0]) +'_raw.set')
     data_len = data_len + raw.n_times/ raw.info.get('sfreq')
  cfg.per_training = round(300/data_len,3)
  cfg.per_valid = round(300/data_len, 3)
  cfg.per_test = 1 - cfg.per_training - cfg.per_valid

  cfg.vec_str_eeg_channel = raw.ch_names
  # str_arch specifies the type of the model to be used
  # if str_arch is not provided then the default model (same as paper)
  # is used. If user wants to define their own model, example on how to do it
  # can be found in models/gru_arch_000.py, the only caveat is that 
  # the name of the file and class name has to be same as the type of the model
  # e.g. gru_arch_000
  
  # random_seed is set to ensure that the splitting of entire dataset into
  # training, validation and test sets is always the same, useful for model
  # selection
  
  # verbose sets the verbosity of Keras during model training
  # 0=silent, 1=progress bar, 2=one line per epoch
  
  # overwrite specifies whether or not to overwrite existing cleaned data
  
  # cv_mode specifies whether or not to use cross validation mode
  # more on this later
 
  s1 = Session(str_sub=str_sub, vec_idx_run=vec_idx_run, str_arch='default_rnn_model',
               random_seed=1997, verbose=2, overwrite=False, cv_mode=False, num_fold=5, cfg=cfg)
  # loads all dataset
  s1.load_all_dataset()
  
  # preform preprocessing of all dataset and initialize model
  s1.prepare_training()

  
  # train the model
  s1.train()
  
  # generate cleaned dataset
  s1.clean()
  
  # Evaluate the performance of the model in terms of RMS and
  # ratio of band power of cleaned dataset in delta, theta 
  # and alpha bands compared to the raw data
  
  # mode specifies which set to evaluate the performance on
  # mode='train' evaluates on training set
  # mode='valid' evaluates on validation set
  # mode='test' evaluates on test set
  s1.evaluate(mode='test')
  # Plot a random epoch from a specified channel and a set
  # str_ch_eeg should be set to standard EEG channel names, e.g. Pz, Fz, Oz etc.
  # mode='train' evaluates on training set
  # mode='valid' evaluates on validation set
  # mode='test' evaluates on test set
  #os.mkdir('/disk1/guangyuan/BCGnet'+sub)
  s1.plot_random_epoch(str_ch_eeg='T8', mode='test',p_figure = Path(cfg.d_data / 'figure'))
  s1.plot_random_epoch(str_ch_eeg='T8', mode='test',p_figure = Path(cfg.d_data / 'figure'))
  s1.plot_random_epoch(str_ch_eeg='T8', mode='test',p_figure = Path(cfg.d_data / 'figure'))
  #Plot the power spectral density (PSD) from the mean/specified channel
  # mode='train' evaluates on training set
  # mode='valid' evaluates on validation set
  # mode='test' evaluates on test set
  
  # str_ch_eeg='avg' plots the mean PSD across all channels
  # str_ch_eeg could also be set to standard EEG channel names, e.g. Pz, Fz, Oz etc.
  s1.plot_psd(str_ch_eeg='avg', mode='test',p_figure = Path(cfg.d_data / 'figure'))
  s1.plot_psd(str_ch_eeg='T8', mode='test',p_figure = Path(cfg.d_data / 'figure'))
  
  # save trained model
  #s1.save_model()
  
  # save cleaned data in .mat files
  # the saved .mat file has one field 'data' which contains the 
  # n_channel by n_time_stamp matrix holding all cleaned data
  
  # note that the unit of the data saved in the mat file 
  # is in Volts instead of in microVolts
  #s1.save_data()
  s1.save_databv()
  # alternatively, save cleaned data in Neuromag .fif format 
  # (note that EEEGLAB support for .fif format is limited)
  # s1.save_dataset()
print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()))
