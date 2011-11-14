Readmill Framework
==================

Dependencies
------------

- iOS4+.
- JSONKit

Installation
------------

1. Clone into ReadmillAPI: 

    `cd /path/to/your/project` 
    `git clone git@github.com:Readmill/ios-wrapper.git ReadmillAPI` 
    (it is important that the name is ReadmillAPI for XCode to find the necessary files)

2. Init and update the JSONKit submodule:  

    `cd ReadmillAPI; git submodule init; git submodule update`

3. Add ReadmillAPI to your workspace:
    Find the ReadmillAPI.xcodeproj file and drag it into the Project Navigator (⌘1).

4. Next, make sure that we can access the ReadmillAPI header files. To do this, add the ReadmillAPI directory 
to the "Header Search Paths" build setting. Start by selecting the "Build Settings" tab of your own project's settings, and 
add `ReadmillAPI/**` to the "Header Search Paths" setting.
![Add header search paths](https://raw.github.com/Readmill/ios-wrapper/master/Documentation/Images/headersearchpaths.png)

5. Now find the 'Other linker flags' settings and add '-ObjC' and '-all_load'. This enables categories in static libraries. 
![Add other linker flags](https://raw.github.com/Readmill/ios-wrapper/master/Documentation/Images/otherlinkerflags.png)

6. With the project settings still selected in the Project Navigator, select the "Build Phases" tab. Under the "Link Binary With Libraries" section, hit the "+" button. In the sheet that appears, select "libReadmillAPI.a" and click "Add".
![Link binary with libReadmillAPI library](https://raw.github.com/Readmill/ios-wrapper/master/Documentation/Images/linkwithlibraries.png)

7. Finally, drag the Readmill.bundle icon to your project and add it to your target. 

For detailed information and documentation on how to use the wrapper, see the [wiki]
(https://github.com/Readmill/ios-wrapper/wiki) and read up on the documentation
in the header files in the framework. Don't forget to check out the example app.

License
-------

The following license (a standard MIT license) applies to all components
in this project, excluding any images and logos containing trademarks 
belonging to Readmill LTD. 

Copyright (c) 2011 Readmill LTD

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
