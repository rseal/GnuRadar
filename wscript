import os
import stat
import sys
import shutil

HOME_DIR = os.environ['HOME']
PROG_INSTALL_DIR='/usr/local/bin/'
PROG_LIB_DIR='/usr/local/lib'
PROJECT_NAME='gnuradar'

################################################################################
# Local method to remove directory tree
################################################################################
def remove_files(d):
   try:
      shutil.rmtree(d)
   except Exception as ex:
      print(ex)

################################################################################
# Installs symlink to include director for development
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
# Installs a copy of header files in /usr/local/include
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
      libs     = ['hdf5','hdf5_hl_cpp','hdf5_cpp','tinyxmlcpp','pthread','usb'],
      cflags   = ['-march=native','-Wall','-02'],
   )

################################################################################
# Builds c++ and java files. Also manages call to install
################################################################################
def build(bld):

   ## build the usrp library
   bld.recurse('usrp')
   bld.recurse('programs/java')

   ### build primary program
   bld(
         name     = 'verify',
         features = 'cxx cxxprogram',
         cxxflags = ['-march=native', '-Wall', '-W'],
         defines  = {'TIXML_USE_TICPP':1},
         includes = ['programs/Verify'],
         source   = 'programs/Verify/GnuRadarVerify.cxx',
         target   = 'gradar-verify-cli',
         libpath  = ['usrp'],
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
         libpath  = ['usrp'],
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
         libpath  = ['usrp'],
         lib      = ['boost_system','boost_filesystem',
                     'tinyxmlcpp','pthread','gnuradar', 
                     'usb','hdf5_hl_cpp','hdf5_cpp','hdf5','rt'],
   )

   ### build Replay
   bld(
         name     = 'replay',
         features = 'cxx cxxprogram',
         cxxflags = ['-march=native', '-Wall', '-W'],
         defines  = {'TIXML_USE_TICPP':1},
         includes = ['programs/Replay'],
         source   = ['programs/Replay/GnuRadarReplay.cxx'],
         target   = 'gradar-replay',
         libpath  = ['usrp'],
         lib      = ['boost_system','boost_filesystem',
                     'tinyxmlcpp','pthread','gnuradar', 
                     'usb','hdf5_hl_cpp','hdf5_cpp','hdf5','rt'],
   )

   bld.add_group()
   bld(
        rule   = 'cp ${SRC} ${TGT}',
        source = bld.path.ant_glob('programs/java/com/lib/xom-1.2.6.jar'),
        target ='programs/java/xom-1.2.6.jar' 
    )

   bld.add_group()
   bld.install_files(
         '${PREFIX}/gnuradar', 
         bld.path.get_bld().ant_glob('programs/java/*.jar')
   )

   bld.install_files(
         '${PREFIX}/gnuradar', 
         bld.path.ant_glob('scripts/*.xml')
   )

   bld.install_files(
      PROG_INSTALL_DIR,
      bld.path.ant_glob('scripts/gradar-*'),
      chmod=stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO
   )

   bld.install_files(
      PROG_LIB_DIR,
      bld.path.ant_glob('usrp/*.la'),
      chmod=stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO
   )

   bld.add_group()

################################################################################
# User configuration file for networking.
################################################################################
def setup_user(ctx):
   shutil.copy('scripts/.gradarrc', HOME_DIR);

