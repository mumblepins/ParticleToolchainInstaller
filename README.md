# ParticleToolchain
Just a compilation of the toolchain required for building the [Particle](http://www.particle.io/) firmware.  Uses the NSIS installer to download and install the components for Windows.

##Windows

###Components
* [GCC ARM Embedded, version 4.9-2015-q2-update](https://launchpad.net/gcc-arm-embedded)
* [Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm)
* [MinGW](http://sourceforge.net/projects/mingw/)
* [Git](https://git-scm.com)
* [Netbeans](https://netbeans.org/)
  * This will install the [Java Development Kit](http://www.oracle.com/technetwork/java/javase/downloads/index.html) if necessary
  * Can also install a basic config file for Netbeans that sets up the Toolchain
* [Cygwin](https://www.cygwin.com/)
* Git pulls the [Particle firmware](https://github.com/spark/firmware), and switches to the [latest branch](https://github.com/spark/firmware/tree/latest)
* Installs the [Particle CLI](https://github.com/spark/particle-cli) and all prequisites necessary
  * [NodeJS](https://nodejs.org/)
  * [MS Build Tools](https://www.microsoft.com/en-us/download/details.aspx?id=40760)
    * Install .NET 4.5.2 if required
  * [Python](https://www.python.org/)
* [dfu-util](http://dfu-util.sourceforge.net/)

The installer will also add the necessary paths to the user PATH environment variable

###Process
1. Run installer, leave all components checked for default install
2. Once everything is done, run a command prompt, type `particle login`, and log into the cloud
3. If you want to use the DFU-util functions, put your device into dfu mode, download [Zadig](http://zadig.akeo.ie/), select the Core/Photon dfu device, select the libusbK driver, click install
4. Start Netbeans, open the project folder located at `(InstallDirectory)\NBProjects` called `ParticleFirmware`
5. Select either Core or Photon as your build target
6. Press the build icon, and find the built files in:
  * Core: `firmware\build\target\main\platform-0-lto\main.bin`
  * Photon: `firmware\build\target\user-part\platform-6-m\user-part.bin`
7. If you want to build as an application, right click on the project, go to properties, and change the appropriate 'make' lines

##License
* All packages are copyright their respective owners.  See individual websites for details.
* Installation files are released under the ISC license
