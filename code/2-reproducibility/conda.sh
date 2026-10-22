#!bin/bash
# This script contains commands for setting up and saving a Conda environment
conda create -n ahds_formative

conda activate ahds_formative

conda install r-base=4.4.1 r-tidyverse=2.0.0 r-janitor=2.2.0 r-haven=2.5.5

conda export --from-history >../../formative_environment.yml

# To remove the environment, run the following commands:
# conda env list
# conda deactivate
# conda env remove -n ahds_formative