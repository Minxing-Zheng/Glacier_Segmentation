#!/usr/bin/env python
"""
Training/Validation Module
"""
from pathlib import Path
import argparse
import os
import re
import numpy as np
import torch
import torch.nn.functional as F
from data import create_dir

def l2_reg(params, device):
    penalty = torch.tensor(0.0).to(device)
    for param in params:
        penalty += torch.norm(param, 2) ** 2
    return penalty


def loss(y_hat, y, params, device, smooth=0.2, weights=[0.6, 0.9, 0.2], lambda_reg=0.0005):
    penalty = l2_reg(params, device)
    dice = dice_loss(y_hat, y, device, weights, smooth)
    bce = bce_loss(y_hat, y, device, weights)
    return dice + bce + lambda_reg * penalty
    #just keep bce
    


def dice_loss(y_hat, y, device, weights, smooth):
    dims = (0,) + tuple(range(2, y.ndimension()))
    intersection = torch.sum(y_hat * y, dims)
    union = torch.sum(y_hat + y, dims)
    dice = 1 - (2. * intersection / (union + smooth))
    weights = torch.Tensor(weights).to(device)
    return (weights * dice).mean()


def bce_loss(y_hat, y, device, weights):
    w_mat = torch.ones_like(y).to(device)
    for k in range(y.shape[1]):
        w_mat[:, k, :, :] = weights[k]
    return F.binary_cross_entropy(y_hat, y, weight=w_mat, reduction="mean")


def train_epoch(model, loader, optimizer, device, epoch=0, save_dir=None):
    loss_ = 0;Loss=[]
    model.train()
    n = len(loader.dataset)#length of dataset, all 
    for i, (x, y) in enumerate(loader):# len(loader)=len(loader.dataset)/batch_size
        x = x.to(device)
        y = y.to(device)

        # gradient step
        optimizer.zero_grad()
        y_hat = model(x)

        if i % 10 == 0 and save_dir is not None:
            np.save(save_dir / f"x-{epoch}-{i}-.npy", x.detach().cpu().numpy())
            np.save(save_dir / f"y-{epoch}-{i}-.npy", y.detach().cpu().numpy())
            np.save(save_dir / f"y_hat-{epoch}-{i}-.npy", y_hat.detach().cpu().numpy())

        l = loss(y_hat, y, model.parameters(), device)
        l.backward()
        optimizer.step()

        # compute losses
        loss_ += l.item()
        Loss.append(l.item())
        log_batch(epoch, i, n, loss_, loader.batch_size)

    return loss_ / n,Loss


def validate(model, loader):
    loss = 0
    model.eval()
    batch_size = False
    for i, (x, y) in enumerate(loader):
        with torch.no_grad():
            y_hat = model(x)
            loss += loss(y_hat, y)

    return loss / len(loader.dataset)


def log_batch(epoch, i, n, loss, batch_size):
    print(
        f"Epoch: {epoch}\tbatch: {i} of {int(n) // batch_size}\tEpoch loss: {loss/batch_size:.5f}",
        end="\r",
        flush=True
    )


def predictions(model, ds, out_dir, device):
    create_dir(out_dir)

    for i in range(len(ds)):
        x, y = ds[i]
        result=re. findall(r"[0-9]+",str(ds.x_paths[i]))
        i1=int(result[0]);i2=int(result[1])
        #i1=int(result[0])
        #print(f"saving {i2 + 1}/{len(ds)}...", end="\r", flush=True)

        with torch.no_grad():
            y_hat = model(x.unsqueeze(0).to(device))
            #np.save(out_dir / f"y_hat-{i1}.npy", y_hat.cpu()[0])
            #np.save(out_dir / f"y-{i1}.npy", y)
            #np.save(out_dir / f"x-{i1}.npy", x)
            np.save(out_dir / f"y_hat-{i1}-{i2}.npy", y_hat.cpu()[0])
            np.save(out_dir / f"y-{i1}-{i2}.npy", y)
            np.save(out_dir / f"x-{i1}-{i2}.npy", x)
