# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-ouf

CONFIG += sailfishapp

SOURCES += src/ouf.cpp \
    src/restaurantmodel.cpp

DISTFILES += qml/harbour-ouf.qml \
    qml/cover/CoverPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/HomePage.qml \
    qml/pages/IngredientsPage.qml \
    qml/pages/RestaurantPage.qml \
    rpm/harbour-ouf.changes.in \
    rpm/harbour-ouf.changes.run.in \
    rpm/harbour-ouf.spec \
    translations/*.ts \
    harbour-ouf.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-ouf-fi.ts

HEADERS += \
    src/restaurantmodel.h

VERSION = 1.0.0
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
