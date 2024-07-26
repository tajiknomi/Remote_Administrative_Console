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
