import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property string restaurant
    property int restaurantIndex
    property var menuData: restaurantModel.getRestaurantMenu(restaurantIndex)

    property string selectedLanguage: {
        // Get system language (like "fi_FI" or "en_US")
        var locale = Qt.locale().name.substring(0, 2);
        if(locale.length > 2) locale = locale.substring(0, 2);
        // If Finnish, use Finnish, otherwise default to English
        return locale === "fi" ? "fi" : "en";
    }

    Connections {
        target: restaurantModel
        onSelectedDateChanged: {
            menuData = restaurantModel.getRestaurantMenu(restaurantIndex)
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        PullDownMenu {
            Repeater {
                model: restaurantModel.getAvailableDates()

                MenuItem {
                    text: modelData.toLocaleDateString()
                    onClicked: restaurantModel.selectedDate = modelData
                }
            }
        }

        Column {
            id: contentColumn
            width: parent.width

            PageHeader {
                title: restaurant
            }

            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Menu for %1").arg(restaurantModel.selectedDate.toLocaleDateString())
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                height: visible ? implicitHeight + Theme.paddingMedium : 0
            }

            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("No menu available for selected date")
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                visible: !menuData.menu || !menuData.menu.en || !menuData.menu.en[0]
            }

            // Menu categories and items
            Repeater {
                model: menuData && menuData.menu && menuData.menu.en ?
                       menuData.menu[selectedLanguage] : []

                delegate: Column {
                    width: parent.width

                    // Category header
                    Item {
                        width: parent.width
                        height: Theme.paddingMedium
                    }

                    Label {
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2 * Theme.horizontalPageMargin
                        text: modelData.name
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeLarge
                        font.bold: true
                    }

                    // Menu items for this category
                    Repeater {
                        model: modelData.items

                        delegate: BackgroundItem {
                            width: page.width
                            height: itemColumn.height

                            Column {
                                id: itemColumn
                                width: parent.width

                                Item {
                                    width: parent.width
                                    height: Theme.paddingSmall
                                }

                                Label {
                                    x: Theme.horizontalPageMargin * 1.5
                                    width: parent.width - 3 * Theme.horizontalPageMargin
                                    text: modelData.name || qsTr("No translation available")
                                    color: parent.parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                                    wrapMode: Text.Wrap
                                    font.pixelSize: Theme.fontSizeMedium
                                }

                                Label {
                                    x: Theme.horizontalPageMargin * 1.5
                                    width: parent.width - 3 * Theme.horizontalPageMargin
                                    text: modelData.diets || ""
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    visible: modelData.diets && modelData.diets.length > 0
                                    wrapMode: Text.Wrap
                                }

                                Item {
                                    width: parent.width
                                    height: Theme.paddingSmall
                                }

                                Rectangle {
                                    visible: index < Repeater.count
                                    width: parent.width - 2 * Theme.horizontalPageMargin
                                    height: 1
                                    color: Theme.secondaryHighlightColor
                                    opacity: 0.2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            onClicked: {
                                pageStack.animatorPush(Qt.resolvedUrl("IngredientsPage.qml"), {
                                    dishName: modelData.name,
                                    ingredients: modelData.ingredients
                                })
                            }
                        }
                    }

                }
            }
            Item {
                width: parent.width
                height: Theme.paddingMedium
            }
        }

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: !menuData || !menuData.menu || menuData.menu.length === 0
            text: qsTr("No menu items available")
            hintText: qsTr("This restaurant may not have published its menu yet")
        }
    }
}
