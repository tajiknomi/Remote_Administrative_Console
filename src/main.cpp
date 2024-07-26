#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "clientlistwrapper.h"
#include "connectionManager.h"

#define CLIENT_TIMEOUT_SEC 30

int main(int argc, char *argv[]){

    QGuiApplication app(argc, argv);

    ConnectionManager *httpServer = new ConnectionManager(&app);
//    httpServer->startServer(80);          // This method is invoked from QML side

    httpServer->setConnectionTimeOut_sec(CLIENT_TIMEOUT_SEC);

    ClientListWrapper *clients = new ClientListWrapper(&app);
    QQmlApplicationEngine Engine;

    Engine.rootContext()->setContextProperty("clients", clients);
    Engine.rootContext()->setContextProperty("httpServer", httpServer);
    Engine.addImportPath("qrc:/");
    Engine.load(QUrl(QStringLiteral("qrc:/resource/qml/Main.qml")));
    if (Engine.rootObjects().isEmpty()){
        return false;
    }
    QObject::connect(httpServer, &ConnectionManager::addClient, clients, &ClientListWrapper::onAddClient);
    QObject::connect(httpServer, &ConnectionManager::removeClient, clients, &ClientListWrapper::onRemoveClient);

    return app.exec();
}
