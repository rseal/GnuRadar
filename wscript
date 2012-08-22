import os
import sys
import shutil

################################################################################
################################################################################
def remove_files(d):
   try:
      shutil.rmtree(d)
   except Exception as ex:
      print(ex)

################################################################################
################################################################################
def install_symlinks(hdr):

   sym_path =  os.path.abspath('include')

   if not os.geteuid()==0:
      sys.exit('\nERROR: Root Acces is required to execute this script.\n')

   dst_dir = '/usr/local/include/gnuradar'

   remove_files(dst_dir)

   try:
      print('Creating Directory Tree...')
      os.symlink(sym_path,dst_dir)
      print('Header installation complete.')
   except Exception as ex:
      print(ex)

################################################################################
################################################################################
def install_headers(hdr):

   if not os.geteuid()==0:
      sys.exit('\nERROR: Root Acces is required to execute this script.\n')

   src_dir = 'include'
   dst_dir = '/usr/local/include/gnuradar'

   remove_files(dst_dir)

   try:
      print('Creating Directory Tree...')
      shutil.copytree(src_dir,dst_dir,symlinks=True)
      print('Header installation complete.')
   except Exception as ex:
      print(ex)

################################################################################
################################################################################
def options(ctx):
   ctx.load('compiler_c compiler_cxx')

################################################################################
################################################################################
def configure(ctx):
   ctx.load('compiler_c compiler_cxx')
   ctx.check(
      features = 'cxx cxxprogram',
      libpath  = [ctx.path.abspath()+'/build/usrp','/usr/lib/','/usr/local/lib'],
      libs     = ['hdf5','hdf5_hl_cpp','hdf5_cpp','tinyxmlcpp','pthread','usb'],
      cflags   = ['-march=native','-Wall','-02'],
   )

################################################################################
################################################################################
def build(bld):

   ## build the usrp library
   bld.recurse('usrp')

   ### build primary program
   bld(
         name     = 'verify',
         features = 'cxx cxxprogram',
         cxxflags = ['-march=native', '-Wall', '-W'],
         defines  = {'TIXML_USE_TICPP':1},
         includes = ['programs/Verify'],
         source   = 'programs/Verify/GnuRadarVerify.cxx',
         target   = 'gradar-verify-cli',
         lib      = ['tinyxmlcpp','pthread','gnuradar', 'usb'],
   )

   ### build Run command-line interface 
   bld(
         name     = 'run-cli',
         features = 'cxx cxxprogram',
         cxxflags = ['-march=native', '-Wall', '-W'],
         defines  = {'TIXML_USE_TICPP':1},
         includes = ['programs/Run'],
         source   = ['programs/Run/GnuRadarRunCli.cxx',
                     'programs/Run/ProducerThread.cxx',
                     'programs/Run/ConsumerThread.cxx'],
         target   = 'gradar-run-cli',
         lib      = ['boost_system','boost_filesystem',
                     'tinyxmlcpp','pthread','gnuradar', 
                     'usb','hdf5_hl_cpp','hdf5_cpp','hdf5','rt'],
   )

   ### build Run server
   bld(
         name     = 'run-server',
         features = 'cxx cxxprogram',
         cxxflags = ['-march=native', '-Wall', '-W'],
         defines  = {'TIXML_USE_TICPP':1},
         includes = ['programs/Run'],
         source   = ['programs/Run/GnuRadarRun.cxx',
                     'programs/Run/ProducerThread.cxx',
                     'programs/Run/ConsumerThread.cxx'],
         target   = 'gradar-run-server',
         lib      = ['boost_system','boost_filesystem',
                     'tinyxmlcpp','pthread','gnuradar', 
                     'usb','hdf5_hl_cpp','hdf5_cpp','hdf5','rt'],
   )

   ### build Run server
   bld(
         name     = 'replay',
         features = 'cxx cxxprogram',
         cxxflags = ['-march=native', '-Wall', '-W'],
         defines  = {'TIXML_USE_TICPP':1},
         includes = ['programs/Replay'],
         source   = ['programs/Replay/GnuRadarReplay.cxx'],
         target   = 'gradar-replay',
         lib      = ['boost_system','boost_filesystem',
                     'tinyxmlcpp','pthread','gnuradar', 
                     'usb','hdf5_hl_cpp','hdf5_cpp','hdf5','rt'],
   )

   ### build Run server
   bld(
         name     = 'replay',
         features = 'cxx cxxprogram',
         cxxflags = ['-march=native', '-Wall', '-W'],
         defines  = {'TIXML_USE_TICPP':1},
         includes = ['programs/Replay'],
         source   = ['programs/Replay/GnuRadarReplay.cxx'],
         target   = 'gradar-replay',
         lib      = ['boost_system','boost_filesystem',
                     'tinyxmlcpp','pthread','gnuradar', 
                     'usb','hdf5_hl_cpp','hdf5_cpp','hdf5','rt'],
   )

   #ctx(
         #name     = 'read',
         #features = 'cxx cxxprogram',
         #cxxflags = ['-march=native', '-Wall', '-W'],
         #includes = ['.','examples'],
         #source   = 'examples/read.cpp',
         #target   = 'read',
         #lib      = ['hdf5','hdf5_hl_cpp','hdf5_cpp'],
   #)
