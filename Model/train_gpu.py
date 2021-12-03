import urllib.request
import tarfile
from pathlib import Path
import os
import pickle
import shutil

args = {
    "batch_size": 2, # make this bigger if you are not running on binder
    "epochs": 30,
    "lr": 0.0001,
    "device": "cuda", # set to "cuda" if GPU is available
    "base_dir": Path("out_process"),
    "save_dir": Path("save_npy")
}

args["save_dir"].mkdir(parents = True, exist_ok=True)

from data import GlacierDataset
from torch.utils.data import DataLoader

paths = {
    "x": sorted(list(args["base_dir"].glob("x*"))),
    "y": sorted(list(args["base_dir"].glob("y*")))
}

ds = GlacierDataset(paths["x"], paths["y"])
loader = DataLoader(ds, batch_size=args["batch_size"], shuffle=False)

import torch.optim
from unet import Unet
from train import train_epoch

model = Unet(9, 3, 4, dropout=0.2).to(args["device"])
optimizer = torch.optim.Adam(model.parameters(), lr=args["lr"])

L=[]
for epoch in range(args["epochs"]):
    l=train_epoch(model, loader, optimizer, args["device"], epoch, args["save_dir"])
    L.append([l[0],l[1]])

torch.save(model.state_dict(), "model.pt")

with open('loss.pkl', 'wb') as f:
    pickle.dump(L, f)
