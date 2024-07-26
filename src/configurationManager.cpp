#include "configurationManager.h"
#include <QDir>
#include <QTcpSocket>
#include <QCoreApplication>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonArray>

const QString ConfigurationManager::moduleDir = "modules";


ConfigurationManager::ConfigurationManager(QObject *parent) : QObject(parent){

        bool isConfigFileAvailable = readConfigFile(configFileName);

        if(isConfigFileAvailable == false){    // If config file is not available, switch to default configuration
            printError("Couldn't find configuration file, Make sure to place " + configFileName + " in the executable directory");
            qDebug() << "Back to default configuration . . .";
            setDefaultConfiguration();
        }

        if(!openLogFile(getLogFilePath(), logFile)){
            printError( "Couldn't open " + getLogFilePath());
        }
}

void ConfigurationManager::printError(const QString &errorMessage){

   qDebug() << errorMessage << " :: " << __FILE__;
}

QByteArray ConfigurationManager::readFile(const QString &filePath, const QIODeviceBase::OpenMode &mode) {

    if(filePath.isEmpty()){
       return QByteArray();
    }
    const QFileInfo fileInfo(filePath);

    if (!fileInfo.exists() || fileInfo.size() == 0) {
        return QByteArray(); // Return empty QString if file doesn't exist or has zero size
    }

    QFile file(filePath);
    if (!file.open(mode)) {
        return QByteArray(); // Return empty QString if unable to open file
    }

    QByteArray fileData = file.readAll();
    file.close();

    return fileData;
}

bool ConfigurationManager::readConfigFile(const QString &fileName) {

    const QString filePath = QFileInfo(QCoreApplication::applicationFilePath()).dir().absoluteFilePath(fileName);

    QByteArray jsonData = readFile(filePath, QIODevice::ReadOnly | QIODevice::Text);

    if(jsonData.isEmpty()){
        //printError ("jsonData is empty");
        return false;
    }

    jsonData.replace("\\", "\\\\");    // Replace single backslash with doulble backslashes because QJsonDocument::fromJson(..) will interpret it as escape characters

    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData, &error);
    if (error.error != QJsonParseError::NoError) {
        printError ("JSON parse error:" + error.errorString());
        return false;
    }

    QJsonObject jsonObject = jsonDoc.object();

    m_dataServerIP = jsonObject["DataServerIP"].toString();

    // Read the LogFilePath from JSON
    QString rawLogFilePath = jsonObject["LogFilePath"].toString();

    // Replace any double backslashes with single backslashes
    m_logFilePath = rawLogFilePath.replace("\\", "\\\\");

//    configData.logFilePath = logFilePath;

    QJsonArray blackListedArray = jsonObject["BlackListedIPs"].toArray();
    QJsonArray DNSListedArray = jsonObject["DNS_list"].toArray();

    for (const QJsonValue &ipValue : blackListedArray) {
        m_blackListedIPs.append(ipValue.toString());
    }

    for (const QJsonValue &dnsValue : DNSListedArray) {
        m_dnsList.append(dnsValue.toString());
    }

    return true;
}

QString ConfigurationManager::GetServerIP(QStringList &dnsList){
    QTcpSocket socket;
    QStringList DNS_list {dnsList};     //{"1.1.1.1","1.0.0.1","8.8.8.8","8.8.4.4"}; // Cloudflare and Google DNS
    for(auto &dns : DNS_list){
        socket.connectToHost(dns, 53);
        if (socket.waitForConnected(500)) {
            return socket.localAddress().toString();
        }
    }
    return QString();       // Return QString(Null) , see https://doc.qt.io/qt-6/qstring.html#distinction-between-null-and-empty-strings
}

QString ConfigurationManager::clientModulesPath() {

    return QCoreApplication::applicationDirPath() + "/" + moduleDir + "/";
}

void ConfigurationManager::setDefaultConfiguration(){

    m_logFilePath = QDir::toNativeSeparators(QDir::homePath()) + "\\logs.txt";
    m_blackListedIPs = QStringList() << "xxx" << "yyy" << "zzz";
    m_dnsList = QStringList() << "1.1.1.1" << "1.0.0.1" << "8.8.8.8" << "8.8.4.4";
    m_dataServerIP = GetServerIP(m_dnsList);
}

bool ConfigurationManager::openLogFile(const QString& logFilePath, QFile &outLogFile) {
    outLogFile.setFileName(logFilePath);
    QTextStream stream(&outLogFile);

    if (outLogFile.exists()) {
        if (outLogFile.open(QIODevice::Append | QIODevice::Text)) {
            return true;
        }
    }
    else {
        if (outLogFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
            stream << "Date&Time\t\t\t\tSource\t\t\t\tDestination\t\t\tData\r\n";
            return true;
        }
    }
    return false; // Return false if file couldn't be opened or created
}

QString ConfigurationManager::getCurrentDateTime(){
    QDateTime currentDateTime = QDateTime::currentDateTime();
    QString formattedDateTime = currentDateTime.toString("dd-MM-yyyy hh:mm:ss");
    return formattedDateTime;
}

QString ConfigurationManager::getDataServerIP() const
{
    return m_dataServerIP;
}

QString ConfigurationManager::getLogFilePath() const
{
    return m_logFilePath;
}

QStringList ConfigurationManager::getBlackListedIPs() const
{
    return m_blackListedIPs;
}

QStringList ConfigurationManager::getDnsList() const
{
    return m_dnsList;
}

void ConfigurationManager::logInput(QString &txt){
    if(txt.isEmpty()){
        return;
    }
    QTextStream stream(&logFile);
    stream << getCurrentDateTime() + "\t\t";
    stream << txt << "\n";
}
