lessThan(QT_MAJOR_VERSION, 5) {
   lessThan(QT_MINOR_VERSION, 15) {
      error("Sorry, you need at least Qt version 5.15.0")
      message( "You use Qt version" $$[QT_VERSION] )
   }
}

# Version Information
VERSION = 1.0.0
VERSTR = '\\"$${VERSION}\\"'  # place quotes around the version string
DEFINES += VER=\"$${VERSTR}\" # create a VER macro containing the version string

# Need Library
QT += quick quickcontrols2 widgets core concurrent

# Compiler
!isEqual(MACHINE, pinephone) {
    message( "You will be compile PC." )
}
else: message( "You will be compile PinePhone." )

CONFIG += c++17

# Config optimization
CONFIG(release, debug|release) {
    CONFIG += optimize_full
}

#QMAKE_CXXFLAGS_RELEASE -= -O1
#QMAKE_CXXFLAGS_RELEASE -= -O2
#QMAKE_CXXFLAGS_RELEASE *= -O3

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

isEqual(MACHINE, pinephone) {
    DEFINES += "PINEPHONE" \
}

SOURCES += \
    main.cpp \
    CAES.cpp \
    CMainWindow.cpp \
    CWorkerThread.cpp

HEADERS += \
    CAES.h \
    CMainWindow.h \
    CWorkerThread.h


RESOURCES += \
    qml.qrc \
    ClearListModel.js \
    Image/Critical.png \
    Image/Directory.png \
    Image/File.png \
    Image/GrepToolQML.png \
    Image/Qt.svg \
    Sound/Warning.mp3 \
    Sound/Warning.wav


DISTFILES += \
    ClearListModel.js \
    Image/Critical.png \
    Image/Directory.png \
    Image/File.png \
    Image/GrepToolQML.png \
    Image/Qt.svg \
    Sound/Warning.mp3 \
    Sound/Warning.wav


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
#qnx: target.path = /tmp/$${TARGET}/bin
#else: unix:!android: target.path = /opt/$${TARGET}/bin
#!isEmpty(target.path): INSTALLS += target

# Config Install directory
isEmpty(PREFIX) {
    PREFIX = $${PWD}/$${TARGET}
}

# Create Desktop Entry file
system([ ! -d Applications ] && mkdir Applications)
system([ -f Applications/GrepToolQML.desktop ] && rm -rf Applications/GrepToolQML.desktop)
system(touch Applications/GrepToolQML.desktop)

system(echo "[Desktop Entry]" >> Applications/GrepToolQML.desktop)
system(echo "Type=Application" >> Applications/GrepToolQML.desktop)
system(echo "Name=GrepToolQML $${VERSION}" >> Applications/GrepToolQML.desktop)
system(echo "GenericName=GrepToolQML" >> Applications/GrepToolQML.desktop)
system(echo "Comment=Tools to grep and editing files and directories" >> Applications/GrepToolQML.desktop)
system(echo "Exec=$${PREFIX}/GrepToolQML %F" >> Applications/GrepToolQML.desktop)
system(echo "Icon=$${PREFIX}/Image/GrepToolQML.png" >> Applications/GrepToolQML.desktop)
system(echo "Categories=Utility\;" >> Applications/GrepToolQML.desktop)
system(echo "Terminal=false" >> Applications/GrepToolQML.desktop)

# Config Install file
Image.path = $${PREFIX}/Image
Image.files = Image/GrepToolQML.png Image/Qt.svg

Sound.path = $${PREFIX}/Sound
Sound.files = Sound/Warning.mp3 Sound/Warning.wav

Applications.path = $${PREFIX}
Applications.files = Applications/GrepToolQML.desktop

target.path = $${PREFIX}
INSTALLS += target Image Sound Applications
