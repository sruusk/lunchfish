import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property string dishName: ""
    property string ingredients: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Ingredients")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: dishName
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                wrapMode: Text.Wrap
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: ingredients || qsTr("No ingredients information available")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.Wrap
            }

            // Add spacing on the bottom
            Item {
                height: Theme.paddingMedium
            }
        }

        VerticalScrollDecorator {}
    }
}
