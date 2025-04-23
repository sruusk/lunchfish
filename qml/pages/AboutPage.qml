import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About")
            }

            // Diet codes section
            SectionHeader {
                text: qsTr("Diet Codes")
            }

            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Vegan (VEG)")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Egg-free (Mu)")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Milk free (M)")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Gluten free (G)")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Lactose free (L)")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Recommended (*)")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            // Application info section
            SectionHeader {
                text: qsTr("Application Information")
            }

            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Menus from: ouf.fi")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Version: %1").arg(Qt.application.version || "debug")
                font.pixelSize: Theme.fontSizeSmall
            }

            // Developer info section
            SectionHeader {
                text: qsTr("Developer")
            }

            BackgroundItem {
                width: parent.width
                height: developerLabel.height + Theme.paddingMedium * 2

                Label {
                    id: developerLabel
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    text: "github.com/sruusk"
                    color: parent.pressed ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.underline: true
                }

                onClicked: Qt.openUrlExternally("https://github.com/sruusk")
            }

            // Bottom padding
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
        }

        VerticalScrollDecorator {}
    }
}
