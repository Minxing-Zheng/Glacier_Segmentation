#!/usr/bin/env bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ksankaran/miniconda3/envs/lakes/lib
eval "$(conda shell.bash hook)"
conda activate /home/ksankaran/miniconda3/envs/lakes


#tar -xvzf glacier_trian.tar.gz 
#rm glacier_trian.tar.gz

for F in *.tar.gz; do
    #tar -zxvf "$F" 
    tar --wildcards -xvzf "$F" '*.npy'
done

rm *gz

git clone https://github.com/krisrs1128/geo_mlvis.git

mv out_process geo_mlvis/Original
cd geo_mlvis/Original

#mkdir npy
#cp *1.npy npy
#cp -R npy $pa
#cd $pa

#rm -rd geo_mlvis

python3 train_gpu.py #$1 $2 

tar -cvzf save_npy.tar.gz save_npy
rm -rd save_npy

cp save_npy.tar.gz $_CONDOR_SCRATCH_DIR
cp *pt $_CONDOR_SCRATCH_DIR
cp *.pkl $_CONDOR_SCRATCH_DIR


