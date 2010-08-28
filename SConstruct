env = Environment()

#define directories
include_dir = '/usr/local/include/gnuradar'
build_dir = 'build'

#install development headers with 'install' argument
headers = [Glob('include/*')]
headers = env.Install(dir = include_dir, source = headers)
env.Alias('install-headers', include_dir, headers)

#call all sub-build scripts
build = env.SConscript('programs/SConstruct')


