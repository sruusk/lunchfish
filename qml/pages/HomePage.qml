import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
//    allowedOrientations: Orientation.All

    Component.onCompleted: {
        restaurantModel.fetchRestaurants()
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: restaurantModel.fetchRestaurants()
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Oulu University Food")
            }
            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Restaurants")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
            BusyIndicator {
                size: BusyIndicatorSize.Large
                anchors.horizontalCenter: parent.horizontalCenter
                running: restaurantModel.count === 0
                visible: restaurantModel.count === 0 && restaurantModel.networkError.length === 0
            }
            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Error loading menus: \n%1").arg(restaurantModel.networkError)
                color: Theme.errorColor
                visible: restaurantModel.networkError.length >= 2
            }
            SilicaListView {
                width: page.width
                height: 800
                model: restaurantModel
                visible: restaurantModel.count !== 0

                delegate: BackgroundItem {
                    id: delegate
                    width: ListView.view.width
                    height: Theme.itemSizeSmall

                    Label {
                        x: Theme.horizontalPageMargin
                        text: name
                        anchors.verticalCenter: parent.verticalCenter
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    onClicked: pageStack.animatorPush(Qt.resolvedUrl("RestaurantPage.qml"),
                        { restaurant: name, restaurantIndex: index })
                }
            }
        }
    }
}
