# E57Tools

This repository contains tools for working with [E57 format](http://www.libe57.org/) 3D data, based on [libE57Format](https://github.com/asmaloney/libE57Format).

Where [libE57Format](https://github.com/asmaloney/libE57Format) is a fork of E57RefImpl modified to strip out everything except the main implementation and compile on macOS, this is a fork of only the tools in the [libE57 source](https://sourceforge.net/p/e57-3d-imgfmt/code/HEAD/tree/trunk/src/) modified to compile on macOS and link against libE57Format:

* `e57validate`
* `e57unpack`

There's also a helper Ruby script, `e57applypose.rb`. This is for transforming split/unpacked CSV output from `e57unpack` to apply the E57 pose transformation, so that you can process each split scan individually in e.g. [CloudCompare](http://www.cloudcompare.org/) without losing the registration between scans.

# Requirements

* libE57Format
* Xerces
* Boost
* CMake

# Compiling

There's now a [Homebrew](https://brew.sh) formula available which you should be able to install with:

    brew install ryanfb/misc/e57tools

Or, on OS X with Xerces installed with `brew install xerces-c` and libE57Format already compiled/installed into the default path:

    mkdir build && cd build
    XERCES_ROOT="/usr/local/Cellar/xerces-c/3.2.2/" LIBE57FORMAT_INSTALL_DIR="/usr/local/E57Format-2.0-x86_64-darwin" cmake ..
    make

You can then optionally use `make install` to copy built binaries into e.g. `/usr/local/bin`. 
