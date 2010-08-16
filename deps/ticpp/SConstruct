env = Environment( CXXFLAGS='-DTIXML_USE_TICPP');

lib_dir = '/usr/local/lib'
lib_name = 'tinyxmlcpp'

header_dir = '/usr/local/include/ticpp'
headers = Glob('*.h')
src = Glob('*.cpp')

full_lib_name = env.SharedLibrary(lib_name, src )
install_lib = env.Install(dir = lib_dir, source = full_lib_name )
install_headers = env.Install(dir = header_dir, source = headers)

env.Alias('install', lib_dir, install_lib);
env.Alias('install', header_dir, install_headers);

