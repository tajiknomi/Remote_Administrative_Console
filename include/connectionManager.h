#ifndef CONNECTIONS_H
#define CONNECTIONS_H

#include <QTcpSocket>
#include <QTcpServer>
#include <QTimer>
#include <QFile>
#include <memory>
#include <QMultiHash>
#include "configurationManager.h"

struct socketMetaData {
    QByteArray buffer;
    size_t totalBytesToRead=0;
    size_t numOfBytesRead=0;
};

class ConnectionManager : public QObject {

    Q_OBJECT

public:
    ConnectionManager(QObject *parent=nullptr);
    unsigned int NumOfClients() const;
    Q_INVOKABLE int startServer(const quint16 &port);
    Q_INVOKABLE void stopServer();
    Q_INVOKABLE void registerTaskForClient(const QString &data);
    void setConnectionTimeOut_sec(const size_t &timeout_sec);

    ConnectionManager(const ConnectionManager&) = delete;     // NO COPY Operation Allowed
    ConnectionManager& operator=(const ConnectionManager&) = delete;

    ConnectionManager(ConnectionManager&&) = delete;          // NO MOVE Operations Allowed
    ConnectionManager& operator=(ConnectionManager&&) = delete;

signals:
    void removeClient(QString id);
    void addClient(QString clientInfo);
    void fileManagerResponse(QString userID, QString response);
    void shellResponse(QString userID, QString response);
    void sendDataServerIP(QString ip);
    void displayPromptQML(QString clientUsername, QString promptMsg);

private slots:
    void onIncommingConnection();
    void onRecvData(QTcpSocket *socket, std::shared_ptr<socketMetaData> tempSocketData);

private:
    ConfigurationManager configManager;
    QTcpServer server;
    unsigned int mNumOfClients;
    size_t clientTimeout_ms = 60 * 1000;
    const QString delimiter = "***";
    QHash<QString,QTimer *> pingTimers;
    static inline size_t s_ConnectionsCount {};
    QMultiHash<QString, QString> pendingClientTasks;

private:
    QString extractContentLength(const QString &packet);
    bool isHttpPacket(const QString &packet);
    size_t extractPacketSize(const QString &packet, const QString &contentLength);
    QString decodeBase64Content(const QString &packet);
    void getCountryLocationFromIP(const std::string& ipAddress, const std::string& clientData);
    void handleClientInstruction(const QString &id, const QString &sourceIp, const QString destIp, const QString &jsonData);
    void setClientTimer (const QString &id, const QString &sourceIp, const QString &jsonData);
    QString constructResponseToRequest (const QString &id);
};

#endif // CONNECTIONS_H
