
#!/usr/bin/env bash

git clone https://github.com/krisrs1128/geo_mlvis.git
Rscript -e "rmarkdown::render('geo_mlvis/test/preprocess.Rmd',params = list(B = ${B}))"
cd geo_mlvis/test
tar -zcvf processed_${B}.tar.gz out_process
mv processed_${B}.tar.gz $_CONDOR_SCRATCH_DIR