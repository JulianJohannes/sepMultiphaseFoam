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

cd postProcessing/interfaceHeight1/0
python3 -c "import pandas as pd; \
    df = pd.read_csv('height.dat', delim_whitespace=True, comment='#', header=None, \
                      names=['time', 'height_above_boundary', 'height_above_location']); \
    df['major_semi_axis_length'] = df['height_above_boundary'] / 2.0; \
    df.to_csv('interface_data.csv', index=False)"


