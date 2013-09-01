Java
====

JSyphon - a Java Native Interface for Syphon

Setup
====

Currently JSyphon has been tested with JOGL via Processing, and LWJGL.

The Test package for JSyphon relies on LWJGL, so if you want to use our test class, be sure to download the LWJGL binaries and place the uncompressed folders inside lib directory, so you have something like:

* Readme.txt
* ant
* bin
* jar
* lib/lwjgl
* native_libs
* native_src
* src

Getting Started:
====

* Make sure that you have also cloned the Syphon-Framework and Shared repos, and they are located at the same level as Java

* Build jsyphon.jar, by running the build script inside the ant folder. The resulting jar file will be placed inside the jar folder.

* Generate the headers by running the script native_src/gen_headers.sh

* Compile the XCode Project to build the native JSyphon JNI libray, named "libJSyphon.jnilib". Build "libJSyphon.jnilib", which includes the Syphon framework, and the JNI code to run in your java app. The compiled "libJSyphon.jnilib" is copied into the "native_libs" folder, where you can then load it in Java using System.load or System.loadLibrary depending on your path setups. We suggest System.loadLibrary.

* To experiment with the JSyphon examples, we provide an Eclipse project which you can import into your workspace, and experiment with "ServerTest.java" and "ClientTest.java" (client coming soon). 

Acknowledgments
====

Initial JSyphon implementation by Skye Book and Anton Marini.
Further refinements by Andres Colubri (server listing, etc).