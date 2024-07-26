#include <QDebug>
#include "clientlistwrapper.h"
#include "client.h"

ClientListWrapper::ClientListWrapper(QObject *parent) : QObject(parent)
{
    // populateModelWithData();
}

void ClientListWrapper::setUsername(int index, const QString &username)
{
    qDebug() << "Changing names to : " << username;
    if(index >= mClients.size())
        return;
    Client * client = static_cast<Client *> (mClients.at(index));
    if( username!= client->username())
    {
        client->setUsername(username);

    }
}

void ClientListWrapper::setSystemname(int index, const QString &systemname)
{
    if(index >= mClients.size())
        return;
    Client * person = static_cast<Client *> (mClients.at(index));
    if( systemname!= person->systemname())
    {
        person->setSystemname(systemname);

    }
}

void ClientListWrapper::setIp(int index, const QString &ip)
{
    if(index >= mClients.size())
        return;
    Client * person = static_cast<Client *> (mClients.at(index));
    if( ip!= person->ip())
    {
        person->setIp(ip);

    }
}

void ClientListWrapper::setLocation(int index, const QString &location)
{
    if(index >= mClients.size())
        return;
    Client * person = static_cast<Client *> (mClients.at(index));
    if( location!= person->location())
    {
        person->setLocation(location);

    }
}

void ClientListWrapper::setOs(int index, const QString &os)
{
    if(index >= mClients.size())
        return;
    Client * person = static_cast<Client *> (mClients.at(index));
    if( os!= person->os())
    {
        person->setOs(os);

    }
}

void ClientListWrapper::setStatus(int index, const QString &status)
{
    if(index >= mClients.size())
        return;
    Client * person = static_cast<Client *> (mClients.at(index));
    if( status!= person->status())
    {
        person->setOs(status);

    }
}

QList<QObject *> ClientListWrapper::Clients() const
{
    return mClients;
}

void ClientListWrapper::setClients(QList<QObject *> mypersons)
{
    if (mClients == mypersons)
        return;

    mClients = mypersons;
    emit clientsChanged(mClients);
}

void ClientListWrapper::printPersons()
{
    qDebug() << "-------------Persons--------------------";
    foreach (QObject * obj, mClients) {
        Client *client = static_cast<Client *> (obj);
        qDebug() << client->username() << " " << client->username() << " " << client->systemname();
    }
}

// ======================== SLOTS ========================
void ClientListWrapper::onAddClient(const QString clientData)
{

    QStringList tmp = clientData.split("***");
    if(tmp.empty()){
        qDebug()<< "clientData recieved by ClientListWrapper::onAddPerson() is empty!!";
        return;
    }
    QString id {tmp[0]};
    QString username {tmp[1]};
    QString systemname {tmp[2]};
    QString os{tmp[3]};
    QString ip{tmp[4]};
    QString location{tmp[5]};
    QString status{};

    Client *client = new Client(this);
    client->setId(id);
    client->setUsername(username);
    client->setSystemname(systemname);
    client->setIp(ip);
    client->setLocation(location);
    client->setOs(os);
    client->setStatus(status);

    mClients.append(client);
    emit clientsChanged(mClients);
}

void ClientListWrapper::onRemoveClient(const QString clientId){

    auto total_clients = mClients.size();
    for (int i=0;i<total_clients;i++){
        Client *c1 = static_cast<Client *>(mClients.at(i));
        if(c1->id() == clientId){
            int index = mClients.indexOf(c1);
            delete c1;
            mClients.removeAt(index);
         //   qDebug() << "Client " << i << " is disconnected";
            break;
        }
    }
    emit clientsChanged(mClients);
}
