import os
env = Environment()

install_prog_dir='/usr/local/bin'
install_prog_dir2='\/usr\/local\/bin'
install_bin=[Glob('bin/gradar*')]
install_lib=[Glob('bin/xom*')]

#define directories
include_dir = '/usr/local/include/gnuradar'
build_dir = 'build'

#install development headers with 'install' argument
headers = [Glob('include/*')]
headers = env.Install(dir = include_dir, source = headers)
env.Alias('install-headers', include_dir, headers)

#install binaries in proper location
bin = env.Install( dir=install_prog_dir, source = install_bin )
lib = env.Install( dir=install_prog_dir, source = install_lib )
env.Alias('install', install_prog_dir, bin)
env.Alias('install', install_prog_dir, lib)

env.Command('bin/gradar-configure','scripts/gradar-configure-default', 
                 [
                    "sed \'s/<LOCATION>/" + install_prog_dir2 + "/\' < $SOURCE > $TARGET",
		    Chmod("$TARGET",0755)
		 ])

env.Command('bin/gradar-verify','scripts/gradar-verify-default',
                 [
                    "sed \'s/<LOCATION>/" + install_prog_dir2 + "/\' < $SOURCE > $TARGET",
		    Chmod("$TARGET",0755)
		 ])





#call all sub-build scripts
build = env.SConscript('programs/SConstruct')

