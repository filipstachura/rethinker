#!/bin/bash

echo "Cleaning..."
rm -rf rethinker
rm rethinker_*.tar.gz
mkdir rethinker
cp -r R rethinker/.
cp DESCRIPTION rethinker/.


echo "Roxygenizing..."
R --vanilla --quiet <<< "library(roxygen2);roxygenise('rethinker')"

echo "Testing..."
R --vanilla --quiet <<< "library(devtools);library(testthat);load_all('rethinker/');test_dir('tests/testthat')"

echo "Building..."
R CMD build rethinker/

echo "Cleaning again..."
rm -rf rethinker/
