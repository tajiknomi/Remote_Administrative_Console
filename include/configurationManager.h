#ifndef CONFIGURATIONMANAGER_H
#define CONFIGURATIONMANAGER_H

#include <QStringList>
#include <QIODevice>
#include <QFile>

class ConfigurationManager : public QObject{

    Q_OBJECT

public:
    ConfigurationManager(QObject *parent=nullptr);

    static void printError(const QString &errorMessage);
    static QByteArray readFile(const QString &filePath, const QIODeviceBase::OpenMode &mode);
    static QString getCurrentDateTime(void);
    static QString GetServerIP(QStringList &dnsList);
    static QString clientModulesPath(void);

    void logInput(QString& str);

    QString getDataServerIP() const;
    QString getLogFilePath() const;
    QStringList getBlackListedIPs() const;
    QStringList getDnsList() const;

public:
    static const QString moduleDir;     // This directory contains files/dlls/modules which need to be send to the client on request.

private:
    const QString configFileName { "config.ini" };
    QFile logFile;
    QString m_dataServerIP;
    QString m_logFilePath;
    QStringList m_blackListedIPs;
    QStringList m_dnsList;

private:
    bool readConfigFile(const QString &fileName);
    bool openLogFile(const QString &logFilePath, QFile &outLogFile);
    void setDefaultConfiguration(void);
    void setConfigurationFromFile(QString &configFilePath);
};


#endif // CONFIGURATIONMANAGER_H
