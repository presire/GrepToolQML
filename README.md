<<<<<<< Updated upstream
# GrepToolQML for PinePhone and Linux PC(x64_64)  

# Preface  
GrepToolQML is a scaling software for PinePhone and Linux PC(x86_64).<br>
<br>

=======
# GrepToolQML for PinePhone and Linux PC(x64_64)

# Preface  
>>>>>>> Stashed changes
GrepToolQML is a software to be able to search, edit, delete, and compare differences easily.<br>
<br>
This article uses Mobian(AArch64) and SUSE Linux Enterprise(x86_64).<br>
<u>you should be able to install it on other Linux distributions as well.</u><br>
(Ex. Manjaro ARM, openSUSE TW, ... etc)<br>
<br>

*Note:*<br>
*GrepToolQML is created in Qt 5.15, so it requires Qt 5.15 library.*<br>
<br>
<br>

# 1. Install the necessary dependencies for GrepToolQML
Create a directory for installing Qt libraries on PinePhone.<br>
* libQt5Core.so.5
* libQt5Gui.so.5
* libQt5Widgets.so.5
* libQt5Concurrent.so.5
* libQt5Quick.so.5
* libQt5QuickControls2.so.5
* libQt5Qml.so.5
* libQt5QmlModels.so.5
* libQt5QuickTemplates2.so.5
* libQt5Network.so.5
<br>
<br>

Get the latest updates on PinePhone.<br>

    sudo apt update  
    sudo apt dist-upgrade  
<br>

Install the dependencies required to build the GrepToolQML.  

    sudo apt install qt5-qmake qt5-qmake-bin \
                     libqt5core5a libqt5widgets5 libqt5gui5 libqt5network5 libqt5concurrent5 \
                     libqt5qml5 libqt5qmlmodels5 libqt5quick5 libqt5quickcontrols2-5 libqt5quicktemplates2-5 libqt5qmlworkerscript5
<br>
<br>

# 2. Compile & Install GrepToolQML
Download the source code from GrepToolQML's Github.<br>

    git clone https://github.com/presire/GrepToolQML.git GrepToolQML

    cd GrepToolQML

    mkdir build && cd build
<br>

Use the qmake command to compile the source code of GrepToolQML.<br>
The default installation directory is <I>**${PWD}/GrepToolQML**</I>.<br>

The recommended installation directory is the home directory. (Ex. <I>**${HOME}/InstallSoftware/GrepToolQML**</I>)

    # for PC
    qmake ../GrepToolQML.pro PREFIX=<The directory you want to install in>

    # for PinePhone
    qmake ../GrepToolQML.pro MACHINE=pinephone PREFIX=<The directory you want to install in>

    make -j $(nproc)
    make install
<br>
    
    cp ../Applications/GrepToolQML.desktop  ~/.local/share/applications
<br>
<br>

# 3. Execute GrepToolQML
Make sure you can execute **GrepToolQML**.<br>
<br>
<center><img src="HC/GrepToolQML_1.png" width="35%" height="35%" ></center><br>
<br>

To search, first, press the round button to select the directory to search.<br>
Next, select the search option (radio button).
At that time, press the [Select] button.
And then, the list view at the top shows the files and directories searched.
<center><img src="HC/GrepToolQML_2.png" width="35%" height="35%" ></center><br>
<br>

To select multiple searched files or directories, double-tap an item.<br>
And then, the text and color display will change from "Multi Select: OFF" to "Multi Select: ON" at the bottom of the list.<br>
<center><img src="HC/GrepToolQML_3.png" width="35%" height="35%" ></center><br>
<br>

**PinePhone only**<br>
To set the editor and diff tools to be used, first, select [Feature] -> [Settings] at the Menu bar.<br>
Next, press the round button to select the executable for the editor and diff tool.<br>
Finally, click on the [Save] button.<br>
<center><img src="HC/GrepToolQML_4.png" width="35%" height="35%" ></center><br>
<br>

To set the color mode, select [Mode] -> [Dark Mode].
Next, press the switch to select Light (Universal Light) or Dark (Material Dark).<br>
After changing the color mode, press the [Application Quit] button.<br>
The software will be automatically restarted and the color mode setting will be reflected.<br>
<center><img src="HC/GrepToolQML_5.png" width="35%" height="35%" ></center><br>
<br>

You can open the context menu by long pressing on the searched files and directories.(**PinePhone only**)<br>
For PC version, the context menu can be displayed by right-clicking the mouse.<br>
<br>
<i>**Note:**</I><br>
<i>**The editor can open a single file.**</I><br>
<i>**Diff Tool can be used to diff 2 files.**</I><br>
<center><img src="HC/GrepToolQML_6.png" width="35%" height="35%" ></center><br>

<br>
<br>
