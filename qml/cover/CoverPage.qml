import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    property int restaurantIndex
    property var menuData: restaurantModel.getRestaurantMenu(restaurantIndex)

    property string selectedLanguage: {
        // Get system language (like "fi_FI" or "en_US")
        var locale = Qt.locale().name.substring(0, 2)
        if(locale.length > 2) locale = locale.substring(0, 2)
        // If Finnish, use Finnish, otherwise default to English
        return locale === "fi" ? "fi" : "en"
    }

    Connections {
        target: restaurantModel
        onSelectedDateChanged: {
            menuData = restaurantModel.getRestaurantMenu(restaurantIndex)
        }
    }


    Column {
        spacing: Theme.paddingSmall
        width: parent.width

        Item {
            height: Theme.paddingSmall
        }

        Label {
            x: Theme.horizontalPageMargin / 2
            text: restaurantModel.selectedDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
            font.pixelSize: Theme.fontSizeExtraSmall
        }

        Label {
            x: Theme.horizontalPageMargin / 2
            text: menuData.name ? menuData.name : ""
            color: Theme.highlightColor
        }

        Repeater {
            model: menuData.menu ? menuData.menu[selectedLanguage] : []

            delegate: Column {
                width: parent.width

                Label {
                    x: Theme.horizontalPageMargin / 2
                    width: parent.width - Theme.horizontalPageMargin
                    text: modelData.items[0].name
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.Wrap
                }
                Rectangle {
                    visible: index < Repeater.count
                    height: 1
                    width: parent.width - Theme.horizontalPageMargin
                    color: Theme.secondaryHighlightColor
                    opacity: 0.2
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: {
                if(restaurantIndex > 0) {
                    restaurantIndex--
                    menuData = restaurantModel.getRestaurantMenu(restaurantIndex)
                }
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                if(restaurantIndex < restaurantModel.count - 1) {
                    restaurantIndex++
                    menuData = restaurantModel.getRestaurantMenu(restaurantIndex)
                }
            }
        }
    }
}
