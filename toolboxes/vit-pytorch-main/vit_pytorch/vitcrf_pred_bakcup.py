# -*- coding: utf-8 -*-
"""
Created on Fri Aug 14 15:00:56 2020

@author: admin
"""

#Partial source : https://github.com/akaraspt/deepsleepnet
import sys
#vitcrfpath = sys.argv[0]
data_direc = sys.argv[1]

import os
vitcrfpath = os.getcwd()
#cd vitcrfpath
import argparse
import glob
import ntpath

import shutil
import numpy as np
import pandas as pd
from mne import Epochs, pick_types, find_events
from mne.io import concatenate_raws, read_raw_edf, read_raw_brainvision
import random
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
from torchvision import datasets, transforms
from tqdm import tqdm
from vit_ss import ViT
from torchcrf import CRF
from sklearn.metrics import f1_score, accuracy_score, classification_report, precision_score, recall_score, cohen_kappa_score, confusion_matrix
import time


print(f"Torch: {torch.__version__}")
batch_size = 64
epochs = 100
lr = 3e-4
gamma = 0.7
seed = 44
earlystop = 50
n_class = 4


def seed_everything(seed):
    random.seed(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True

if torch.cuda.is_available():
        print('Using GPU')
        device = 'cuda'
        seed_everything(seed)
else:
        print('Using CPU')
        device = 'cpu'

    


class TimeDistributed(nn.Module):
    def __init__(self, module, batch_first):
        super(TimeDistributed, self).__init__()
        self.module = module
        self.batch_first = batch_first

    def forward(self, input_seq,tags):
        assert len(input_seq.size()) > 2

        # reshape input data --> (samples * timesteps, input_size)
        # squash timesteps
        reshaped_input = input_seq.contiguous().view(-1, input_seq.size(-3),input_seq.size(-2),input_seq.size(-1))

        output = self.module(reshaped_input)
        # We have to reshape Y
        if self.batch_first:
            # (samples, timesteps, output_size)
            output = output.contiguous().view(input_seq.size(0), -1, output.size(-1))
        else:
            # (timesteps, samples, output_size)
            output = output.contiguous().view(-1, input_seq.size(1), output.size(-1))
        return output,tags
    


class vit_crf(nn.Module):
    def __init__(self,vitmodel,batch_first=False):
        super().__init__()
        #self.module = vitmodel
        #self.batch_first = batch_first
        self.TimeD = TimeDistributed(vitmodel,batch_first=batch_first)
        self.crf= CRF(n_class,batch_first).to(device)
    def forward(self,input_seq,label):
        emission,tag = self.TimeD(input_seq,label)
        out = self.crf(emission,tag)
        return out
    def decode(self,input_seqs,tags=None):
        emissions,tags = self.TimeD(input_seqs,tags)
        return self.crf.decode(emissions)



test_transforms = transforms.Compose(
    [
       # transforms.Resize((224, 224)),
      #  transforms.RandomResizedCrop(224),
       # transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
    ]
    )

class SSDataset(Dataset):
        def __init__(self, file_list, transform=None):
          self.file_list = file_list
          self.transform = transform

        def __len__(self):
          self.filelength = len(self.file_list)
          return self.filelength

        def __getitem__(self, idx):
          #img_path = self.file_list[idx]
          #img = Image.open(img_path)
          #data = np.load(img_path)
          img = x[idx,...]
          mu = np.mean(img,axis=0)
          std = np.std(img,axis=0)
          img = (img-mu)/std
          img_transformed = self.transform(img)
          return img_transformed, label, img_path
#test_data = SSDataset(test, transform=test_transforms)

#test_loader = DataLoader(dataset = test_data, batch_size=batch_size, shuffle=False)


#print(len(valid_data), len(valid_loader))
#print(len(test_data), len(test_loader))


vitmodel = ViT(
    image_size = [3000, 10],
    patch_size = [100,10],
    num_classes = n_class,
    dim = 128,
    depth = 6,
    heads = 8,
    mlp_dim = 128,
    dropout = 0.1,
    emb_dropout = 0.1
    ).to(device)

net = vit_crf(vitmodel,batch_first=True)
net = torch.load(vitcrfpath + '/trained_vitcrf.pt',map_location=torch.device(device));
# Label values
W = 0
N1 = 1
N2 = 2
N3 = 3
R = 4
UNKNOWN = 5

stage_dict = {
    "W": W,
    "N1": N1,
    "N2": N2,
    "N3": N3,
    "R": R,
    "UNKNOWN": UNKNOWN
}


class_dict = {
    0: "W",
    1: "N1",
    2: "N2",
    3: "N3",
    4: "R",
    5: "UNKNOWN"
}

ann2label = {
    "Sleep stage W": 0,
    "Sleep stage 1": 1,
    "Sleep stage 2": 2,
    "Sleep stage 3": 3,
    "Sleep stage 4": 3,
    "Sleep stage R": 4,
    "Sleep stage ?": 5,
    "Movement time": 5
}

EPOCH_SEC_SIZE = 30


#select_c=["E2-M2","E1-M2","F3-M1","F4-M2","C3-M1","C4-M2","O1-M1","O2-M2","Chin1-Chin2","Chin3-Chin2"]
select_c1=["E1","E2","F3","F4","C3","C4","O1","O2","EMG1","EMG2"]
select_c2=["EOG1","EOG2","F3","F4","C3","C4","O1","O2","EMG1","EMG2"]



all_test_preds = []
all_test_gt = []
all_test_loss = 0
subs_pred = []
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", type=str, default='.',
                        help="File path to the CSV or NPY  file that contains walking data.")
    parser.add_argument("--output_dir", type=str, default='.',
                        help="Directory where to save outputs.")
    parser.add_argument("--select_ch", type=str, default=select_c1,
                        help="File path to the trained model used to estimate walking speeds.")
    args = parser.parse_args()

    # Output dir
    #if not os.path.exists(args.output_dir):
    #    os.makedirs(args.output_dir)
    args.output_dir = args.data_dir
    # Select channel
    select_ch = args.select_ch

    # Read raw and annotation EDF files
    psg_fnames = glob.glob(os.path.join(args.data_dir, "*.vhdr"))
   # ann_fnames = glob.glob(os.path.join(args.data_dir, "*.txt"))
    psg_fnames.sort()
    #ann_fnames.sort()
    psg_fnames = np.asarray(psg_fnames)
    #ann_fnames = np.asarray(ann_fnames)
        
    for i in range(len(psg_fnames)):
        raw = read_raw_brainvision(psg_fnames[i], preload=True)
        #raw.resample(100)
        sampling_rate = raw.info['sfreq']
        try:
            raw_ch_df = raw.to_data_frame(scalings=1)[select_c1]
        except:
            args.select_ch=select_c2
            select_ch=args.select_ch
            raw_ch_df = raw.to_data_frame(scalings=1)[select_c2]
        #raw_ch_df = raw_ch_df.to_frame()
        raw_ch_df.set_index(np.arange(len(raw_ch_df)))
        
 
        select_idx = np.arange(len(raw_ch_df))
        # Remove movement and unknown stages if any
        raw_ch = raw_ch_df.values[select_idx]*1e6

        # Verify that we can split into 30-s epochs
        if len(raw_ch) % (EPOCH_SEC_SIZE * sampling_rate) != 0:
            raise Exception("Something wrong!Not multiples of 30s")
            print(i)
        n_epochs =int( len(raw_ch) / (EPOCH_SEC_SIZE * sampling_rate))

        # Get epochs and their corresponding labels
        x = np.asarray(np.split(raw_ch, n_epochs)).astype(np.float32)
        print(i)
        test_data = SSDataset(x,transform=test_transforms)
        test_loader = DataLoader(dataset = test_data, batch_size=batch_size, shuffle=False)
        print(len(test_data), len(test_loader))
        sub_pred = []
        for data in test_loader:
            data = data.unsqueeze(axis=0)
            data = data.to(device)
            test_pred = net.decode(data)[0]
            if type(test_gt) == int:
                test_gt = [test_gt]
            all_test_preds += test_preds
            sub_pred += preds
        np.savetxt('stage_pred'+str(i),'.txt',sub_pred)
'''
        filename = ntpath.basename(psg_fnames[i]).replace(".edf", ".npz")
        save_dict = {
            "x": x, 
            "y": y, 
            "fs": sampling_rate,
            "ch_label": select_ch,
            #"header_raw": h_raw,
            #"header_annotation": h_ann,
        }
        #np.savez(os.path.join(args.output_dir, filename), **save_dict)
        
        all_rows = x
        num_epoch = all_rows.shape[0]
        for j in range(num_epoch):
                X = all_rows[j, ...]
                Y = y[j]
                save_dict = {
                    "x": X, 
                    "y": Y, 
                    "fs": sampling_rate,
                    "ch_label": select_ch,
                   # "header_raw": h_raw,
                   #"header_annotation": h_ann,
                }
                if Y != 5:
                  if Y != 4:
                    filename = ntpath.basename(psg_fnames[i][0:-4]+'epoch'+'%03d' % j +'.npz')
                    np.savez(os.path.join(args.output_dir,filename), **save_dict)

        print("\n=======================================\n")
'''

if __name__ == "__main__":
    main()

