#!/bin/sh

############
## README ##
############
## Purpose
## This script executes all _spec.rb files within an applet and generates html reports for them. It stores the reports
## in ./reports/ then zips the ./reports/ directory and all contents into a provided filename. The script will
## retain the directory structure in which the specs were organized within the /spec/ directory.
## Ex:  The following tests under /spec/
##      /spec/loginTests/loginhelper.rb
##      /spec/loginTests/login1_spec.rb
##      /spec/loginTests/login2_spec.rb
## would generate a /reports/ directory with /loginTests/login1_spec.html and /loginTests/login2_spec.html
############
## Prerequisites
## This script should be placed one step above the spec directory in your project
## The specs to be ran should be in either spec/* or spec/**/*
## The specs should have the rspec file naming standard  ex:  *_spec.rb
############
##Usage: ./executeTestGenerateReports.sh {report name}.zip
##ex     ./executeTestGenerateReports.sh vitals-test-reports.zip
############

rm -rf reports
mkdir reports

for i in $(find spec -name '*_spec.rb');
do
    emptyStr=''
    ext=${i##*/}
    fname=${ext%.*}
    outDir="${i/spec\//$emptyStr}.html"
    mkdir -p `dirname reports/$outDir`
    rspec $i --format h > reports/$outDir
done
zip $@ reports/*