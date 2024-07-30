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
// SOFTWARE.

#ifndef CLIENTLISTWRAPPER_H
#define CLIENTLISTWRAPPER_H

#include <QObject>


std::string find_localIpAddress(void);


class ClientListWrapper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> mClients READ Clients WRITE setClients NOTIFY clientsChanged)

public:
    explicit ClientListWrapper(QObject *parent = nullptr);
    Q_INVOKABLE void setUsername(int index, const QString &username);
    Q_INVOKABLE void setSystemname(int index, const QString &systemname);
    Q_INVOKABLE void setIp(int index,const QString &ip);
    Q_INVOKABLE void setLocation(int index, const QString &location);
    Q_INVOKABLE void setOs(int index, const QString &os);
    Q_INVOKABLE void setStatus(int index,const QString &status);
    QList<QObject*> Clients() const;
    void setClients(QList<QObject*> mypersons);

public slots:
    void onAddClient(const QString clientData);
    void onRemoveClient(const QString clientID);

signals:
    void clientsChanged(QList<QObject*> mypersons);

private:
    void printPersons();
    QList<QObject *> mClients;   // This should be QObject*, Person* is not going to work in QML
};

#endif // CLIENTLISTWRAPPER_H
