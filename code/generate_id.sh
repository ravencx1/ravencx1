#!/bin/bash

 > data/derived/accel_id.csv
ls data/derived/accel | grep -Eo '[0-9]+' > data/derived/pids-with-accel.txt
