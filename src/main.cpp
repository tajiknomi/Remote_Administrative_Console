// Copyright (c) Nouman Tajik [github.com/tajiknomi]
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE. 1 



#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "clientlistwrapper.h"
#include "connectionManager.h"

#define CLIENT_TIMEOUT_SEC 50

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
