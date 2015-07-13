# ParticleToolchain
Just a compilation of the toolchain required for building the [Particle](http://www.particle.io/) firmware.

##Components
* [GCC ARM Embedded, version 4.9-2015-q1-update](https://launchpad.net/gcc-arm-embedded)
* [Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm)
* [MinGW](http://sourceforge.net/projects/mingw/)

##License
* All packages are copyright their respective owners.  See individual websites for details.
* Batch files in root directory are released under GPL v3.

##Installation
Recommendation is to install in a path with no spaces for simplicities sake.  I'd recommend installing [git](https://git-scm.com/download/win) if you haven't already, it's a great tool.  If you have git installed already, you can just run the following to install (from a command prompt) on Windows in C:\ParticleToolchain:
```
c: && cd \ && git clone https://github.com/mumblepins/ParticleToolchain && cd ParticleToolchain && addPath.bat
```
This will clone the repository, and add the toolchain to the path.  If you want to remove the toolchain, all you have to do is run removePath.bat from the install directory, and then delete the directory.

After the toolchain is installed, all you should have to do is clone the (firmware repository)[https://github.com/spark/firmware], and run make in that directory!

Please file bugs if this isn't working, and I'll try to update as new versions of the GCC ARM toolchain come out and are compatible with the Particle firmware.
