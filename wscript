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
   bld.recurse('protobuf')
   bld.recurse('programs/java')

   bld.add_group()

   ### build Run server
   bld(
         name     = 'run-server',
         features = 'cxx cxxprogram',
         cxxflags = ['-march=native', '-Wall', '-W'],
         includes = common_include + ['programs/Run','protobuf'],
         source   = ['programs/Run/GnuRadarRun.cxx',
                     'programs/Run/ProducerThread.cxx',
                     'programs/Run/ConsumerThread.cxx'], 
         target   = 'gradar-run-server',
         libpath  = ['usrp','/usr/lib','/usr/local/lib'],
         lib      = ['boost_system','boost_filesystem','zmq',
                     'yaml-cpp','pthread','gnuradar','protobuf',
                     'usb-1.0','hdf5_hl_cpp','hdf5_cpp','hdf5','rt'],
         use = 'proto'
   )

   ### build Replay
   bld(
         name     = 'replay',
         features = 'cxx cxxprogram',
         cxxflags = ['-march=native', '-Wall', '-W'],
         includes = common_include + ['programs/Replay'],
         source   = ['programs/Replay/GnuRadarReplay.cxx'],
         target   = 'gradar-replay',
         libpath  = ['usrp','/usr/lib','/usr/local/lib'],
         lib      = ['boost_system','boost_filesystem','protobuf',
                     'yaml-cpp','pthread','gnuradar', 
                     'usb-1.0','hdf5_hl_cpp','hdf5_cpp','hdf5','rt'],
         use = 'proto'
   )

   bld.add_group()
   bld(
        rule   = 'cp ${SRC} ${TGT}',
        source = bld.path.ant_glob('programs/java/com/lib/snakeyaml-1.10.jar'),
        target ='programs/java/snakeyaml-1.10.jar' 
    )

   bld(
        rule   = 'cp ${SRC} ${TGT}',
        source = bld.path.ant_glob('programs/java/com/lib/zmq.jar'),
        target ='programs/java/zmq.jar' 
    )

   bld(
        rule   = 'cp ${SRC} ${TGT}',
        source = bld.path.ant_glob('programs/java/com/lib/protobuf-java-2.5.0.jar'),
        target ='programs/java/protobuf-java-2.5.0.jar'
    )


   bld.add_group()
   bld.install_files(
         '${PREFIX}/gnuradar', 
         bld.path.get_bld().ant_glob('programs/java/*.jar')
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

