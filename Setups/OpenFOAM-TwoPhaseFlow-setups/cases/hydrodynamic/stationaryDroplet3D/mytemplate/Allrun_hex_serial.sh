#!/usr/bin/env bash

set -o verbose

rm -rf 0 && cp -r 0.org 0  
find 0/ -name "*.template" -delete && \
touch "$(basename ${PWD}).foam" && \
set -o errexit

# Create mesh
blockMesh

# Initialize data 
leiaSetFields -alphaName alpha.dispersed

leiaLevelSetTwoPhaseFoam 

cd postProcessing/
python3 -c "import pandas as pd; \
    dfmax = pd.read_csv('minMaxU/0/fieldMinMax.dat', delim_whitespace=True, \
                        comment='#', header=None, names=['time', 'min_error_velocity', 'max_error_velocity']); \
    dfl1 = pd.read_csv('l1normU/0/volFieldValue.dat', delim_whitespace=True, comment='#', header=None); \
    dfl2 = pd.read_csv('l2normU/0/volFieldValue.dat', delim_whitespace=True, comment='#', header=None); \
    dfmax['mean_absolute_error_velocity'] = dfl1[1]; \
    dfmax['root_mean_square_deviation_velocity'] = dfl2[1]; \
    dfmax.to_csv('velocity_data.csv', index=False)"
