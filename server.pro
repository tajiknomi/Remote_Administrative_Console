QT += quick
QT += network
QT += httpserver

#win32:RC_ICONS += applicationIcon.ico           // place the icon in the project directory and uncomment this line

# You can make your code fail to compile if it uses deprecated APIs
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += src/client.cpp \
          src/clientlistwrapper.cpp \
          src/configurationManager.cpp \
          src/connectionManager.cpp \
          src/json.cpp \
          src/main.cpp

# Specify the include path
INCLUDEPATH += include

# List the headers correctly
HEADERS += include/client.h \
           include/clientlistwrapper.h \
           include/configurationManager.h \
           include/connectionManager.h \
           include/json.h

RESOURCES += \
    resources.qrc

DISTFILES += resource/Clients_header.qml \
             resource/Dialog1.qml \
             resource/Dialog2.qml \
             resource/Filemanager.qml \
             resource/Main.qml \
             resource/ShellWindow.qml \
             resource/ShowPrompt.qml
