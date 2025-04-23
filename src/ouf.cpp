#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QQuickView>
#include <QQmlContext>
#include "restaurantmodel.h"

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/ouf.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //   - SailfishApp::pathToMainQml() to get a QUrl to the main QML file
    //
    // To display the view, call "show()" (will show fullscreen on device).

	//    return SailfishApp::main(argc, argv);

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    // Create and register the restaurant model
    RestaurantModel *restaurantModel = new RestaurantModel();
    view->rootContext()->setContextProperty("restaurantModel", restaurantModel);

    // Set the main QML file
    view->setSource(SailfishApp::pathToMainQml());

    // Show the application window
    view->show();

    app->setOrganizationName(QStringLiteral("org.sruusk"));
    app->setApplicationName(QStringLiteral("OUF"));

    return app->exec();
}
