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
