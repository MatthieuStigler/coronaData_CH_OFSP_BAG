#!/bin/bash
## Run R
Rscript --vanilla code/0_1_download_BAG_OFSP.R #> /dev/null 2>&1 &
Rscript --vanilla code/0_2_docs_process.R 
Rscript --vanilla code/0_3_check_data.R 
Rscript --vanilla code/0_6_visualize_plots.R 
rm -f Rplots.pdf

## GIT stuff

git_mess="Automatic update, $(date +'%d %b %Y')"
git status
git add data_raw/OFSP_report_downloaded*
git commit data_raw/* data_final/* output/figures/* -m "$git_mess"
git push origin master
echo "Done"

