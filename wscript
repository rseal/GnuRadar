import os
import stat
import sys
import shutil

HOME_DIR = os.environ['HOME']
PROG_INSTALL_DIR='/usr/local/bin/'
PROG_LIB_DIR='/usr/local/lib/'
PROJECT_NAME='gnuradar'

################################################################################
# Loads c++ and java compiler options
################################################################################
def options(ctx):
   ctx.load('compiler_c compiler_cxx')
   ctx.load('java')

################################################################################
# Loads c++ and java compiler options
################################################################################
def configure(ctx):
   ctx.load('compiler_c compiler_cxx')
   ctx.load('java')
   ctx.check(
      features = 'cxx cxxprogram',
      libpath  = [ctx.path.abspath()+'/build/usrp','/usr/lib/','/usr/local/lib'],
      libs     = ['hdf5','hdf5_hl_cpp','hdf5_cpp','yaml-cpp','pthread','usb-1.0'],
      cflags   = ['-march=native','-Wall','-02'],
   )

################################################################################
# Builds c++ and java files. Also manages call to install
################################################################################
def build(bld):

   # defines paths for dependencies and local files
   common_include = ['include','deps/hdf5r/include','deps/clp/include','usrp/include']

   ## build the usrp library
   bld.recurse('usrp')

   bld.add_group()

   ### build Main program
   bld(
         name     = 'pisco',
         features = 'cxx cxxprogram',
         cxxflags = ['-march=native', '-Wall', '-W'],
         includes = common_include + ['programs/Run'],
         source   = ['programs/Run/IonosondeRxRun.cpp', 
                     'programs/Run/ProducerThread.cxx',
                     'programs/Run/ConsumerThread.cxx'
                    ], 
         target   = 'pisco',
         libpath  = ['usrp','/usr/lib','/usr/local/lib'],
         lib      = ['boost_system','boost_filesystem','zmq',
                     'yaml-cpp','pthread','gnuradar','protobuf',
                     'usb-1.0','hdf5_hl_cpp','hdf5_cpp','hdf5','rt'],
         #use = 'proto'
   )


   bld.install_files(
         '${PREFIX}/gnuradar', 
         bld.path.ant_glob('scripts/*.yml')
   )

   bld.install_files(
      PROG_INSTALL_DIR,
      bld.path.ant_glob('scripts/gradar-*'),
      chmod=stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO
   )

   bld.add_group()

################################################################################
# User configuration file for networking.
################################################################################
def setup_user(ctx):
   shutil.copy('scripts/.gradarrc', HOME_DIR);

