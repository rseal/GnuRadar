import os
env = Environment()

HOME_DIR = os.environ['HOME']

# configuration directory and file
install_config_dir='/usr/local/gnuradar'
config_file='scripts/gnuradar_server.xml'
config = env.Install( dir=install_config_dir, source = config_file )
env.Alias('install-config', install_config_dir, config)


#install development headers with 'install' argument
include_dir = '/usr/local/include/gnuradar'
headers = [Glob('include/*')]
headers = env.Install(dir = include_dir, source = headers)
env.Alias('install-headers', include_dir, headers)

#install binaries in proper location
install_prog_dir='/usr/local/bin'
install_bin=[Glob('bin/gradar*')]
install_lib=[Glob('bin/xom*')]
bin = env.Install( dir=install_prog_dir, source = install_bin )
lib = env.Install( dir=install_prog_dir, source = install_lib )
env.Alias('install', install_prog_dir, bin)
env.Alias('install', install_prog_dir, lib)

#install user rc file - do not run as root.
config = env.Install( dir=HOME_DIR, source = 'scripts/.gradarrc')
env.Alias('install-rc', HOME_DIR, config )

# The following three commands modify default template files in the 
# scripts directory. The resulting scripts are installed in the 
# bin folder. The scripts are wrappers for java programs.
# There's likely a much simpler way to do this - but it's not obvious
# so I'll leave it for someone else to solve.
install_prog_dir2='\/usr\/local\/bin'
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

env.Command('bin/gradar-run','scripts/gradar-run-default',
                 [
                    "sed \'s/<LOCATION>/" + install_prog_dir2 + "/\' < $SOURCE > $TARGET",
		    Chmod("$TARGET",0755)
		 ])

#call all sub-build scripts
build = env.SConscript('programs/SConstruct', CPPPATH=Glob('/usr/local/include/gnuradar'))

