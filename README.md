# ParticleToolchain
Just a compilation of the toolchain required for building the [Particle](http://www.particle.io/) firmware.  Uses the NSIS installer to download and install the components for Windows.  For the Particle CLI setup, go [here](https://github.com/mumblepins/particle-cli-installer)

##Windows

###Components
* [GCC ARM Embedded](https://launchpad.net/gcc-arm-embedded)
* [Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm)
* [MinGW](http://sourceforge.net/projects/mingw/)
* [Git](https://git-scm.com)
* [Netbeans](https://netbeans.org/)
  * This will install the [Java Development Kit](http://www.oracle.com/technetwork/java/javase/downloads/index.html) if necessary
* [Cygwin](https://www.cygwin.com/)
* Git pulls the [Particle firmware](https://github.com/spark/firmware), and switches to the [latest branch](https://github.com/spark/firmware/tree/latest)


The installer will also add the necessary paths to the user PATH environment variable

###Process
1. Run installer, leave all components checked for default install
2. Start Netbeans, open the project folder located at `(InstallDirectory)\NBProjects` called `ParticleFirmware`
3. Follow the guide at https://youtu.be/l1gk1s2MDpo for Netbeans setup info
4. Select either Core or Photon as your build target
5. Press the build icon, and find the built files in:
  * Core: `firmware\build\target\main\platform-0-lto\main.bin`
  * Photon: `firmware\build\target\user-part\platform-6-m\user-part.bin`
6. If you want to build as an application, right click on the project, go to properties, and change the appropriate 'make' lines


### General build instructions
See [the Particle firmware docs](https://github.com/spark/firmware/blob/develop/docs/build.md) for building from the command line

In general, a `make` or `make PLATFORM=photon` should compile successfully from the root of the firmware directory, assuming all of the PATH items got set correctly.  You may need a reboot of the computer between installation and successfull making, to help Windows figure out it's stuff.

##License
* All packages are copyright their respective owners.  See individual websites for details.
* Installation files are released under the ISC license
