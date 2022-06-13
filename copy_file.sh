#!/bin/bash

# Setting paths
top="user_proj_example"
# base_dir="/home/users/jakeke/Synthesis-Fast-ANN-Fieldious/skywater-digital-flow/FastANNFieldiousCaravel"
base_dir="/home/users/jakeke/synth_clk/skywater-digital-flow/FastANNFieldiousCaravel"
build_target="build"

gds_path="$base_dir/$build_target/*-signoff/outputs/design-merged.gds"
# gds_path="$base_dir/$build_target/*-gdsmerge/design_merged.gds"
# gds_path="/home/users/jakeke/Synthesis-Fast-ANN-Fieldious/skywater-digital-flow/FastANNFieldiousCaravel/build/21-mentor-calibre-gdsmerge/design_merged.gds"
lef_path="$base_dir/$build_target/*-signoff/outputs/design.lef"
def_path="$base_dir/$build_target/*-signoff/outputs/design.def.gz"
gl_path="$base_dir/$build_target/*-signoff/outputs/design.vcs.pg.v"
spef_path="$base_dir/$build_target/*-signoff/outputs/design.spef.gz"
sdf_path="$base_dir/$build_target/*-pt-timing-signoff/outputs/design.sdf"
rtl_path="$base_dir/$build_target/4-rtl/outputs/design.v"
spi_path="$base_dir/$build_target/*-gds2spice/outputs/design_extracted.spice"

# Create file names

gds_file="./gds/$top.gds"
lef_file="./lef/$top.lef"
def_file="./def/$top.def.gz"
gl_file="./verilog/gl/$top.v"
spef_file="./spef/$top.spef.gz"
sdf_file="./sdf/$top.sdf"
rtl_file="./verilog/rtl/$top.v"
spi_file="./spi/lvs/$top.spice"

# Remove old files
if [ -f $gds_file ]; then
      rm -rf $gds_file
      echo "Removed existing $gds_file"
fi
if [ -f $lef_file ]; then
      rm -rf $lef_file
      echo "Removed existing $lef_file"
fi
if [ -f $def_file ]; then
      rm -rf $def_file
      echo "Removed existing $def_file"
fi
if [ -f $sdf_file ]; then
      rm -rf $sdf_file
      echo "Removed existing $sdf_file"
fi
if [ -f $gl_file ]; then
      rm -rf $gl_file
      echo "Removed existing $gl_file"
fi
if [ -f $spef_file ]; then
      rm -rf $spef_file
      echo "Removed existing $spef_file"
fi
# if [ -f $rtl_file ]; then
#       rm -rf $rtl_file
#       echo "Removed existing $rtl_file"
# fi
#if [ -f $spi_file ]; then
#    rm -rf $spi_file
#    echo "Removed existing $spi_file"
#fi

# Moving files
echo "Moving $gds_path to $gds_file"
cp $gds_path $gds_file
echo "Moving $lef_path to $lef_file"
cp $lef_path $lef_file
echo "Moving $def_path to $def_file"
cp $def_path $def_file
echo "Moving $sdf_path to $sdf_file"
cp $sdf_path $sdf_file
echo "Moving $gl_path to $gl_file"
cp $gl_path $gl_file
echo "Moving $spef_path to $spef_file"
cp $spef_path $spef_file
# echo "Moving $rtl_path to $rtl_file"
# cp $rtl_path $rtl_file
#echo "Moving $spi_path to $spi_file"
#cp $spi_path $spi_file

#unzip .gz files
echo "gunzip $def_file"
gunzip $def_file
echo "gunzip $spef_file"
gunzip $spef_file