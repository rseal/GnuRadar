from distutils.core import setup

# glob containing install files
files = ["gnuradar/*"]

setup(name = "gradar-plot",
    version = "1.0",
    description = "Real-time plotting application for use with gnuradar",
    author = "Ryan Seal",
    author_email = "rlseal@gmail.com",
    url = "",
    packages = ['gnuradar'],
    package_data = {'gnuradar' : files },
    scripts = ["gradar-plot"],
) 
