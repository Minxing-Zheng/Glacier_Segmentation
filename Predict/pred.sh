#!/usr/bin/env bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ksankaran/miniconda3/envs/lakes/lib
eval "$(conda shell.bash hook)"
conda activate /home/ksankaran/miniconda3/envs/lakes


tar -xvzf test.tar.gz
rm test.tar.gz

cd test 

for F in *.tar.gz; do
    #tar -zxvf "$F" 
    tar --wildcards -xvzf "$F" '*.npy'
done

rm *gz

mv out_process ..

cd ..

#cd geo_mlvis/test/processed
#kdir npy
#cp *1.npy npy
#cp -R npy $pa
#cd $pa
#rm -rd geo_mlvis
#mv out_process npy


git clone https://github.com/krisrs1128/geo_mlvis.git
cp model.pt geo_mlvis/Original
mv out_process geo_mlvis/Original
#rm -rd out_process
cd geo_mlvis/Original

python3 save_preds.py

rm -rd out_process

tar -cvzf predictions.tar.gz predictions

mv predictions.tar.gz $_CONDOR_SCRATCH_DIR



