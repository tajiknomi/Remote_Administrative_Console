#include "client.h"

Client::Client(QObject *parent) : QObject(parent)
{

}

Client::Client(const QString &username, const QString &systemname, const QString &ip, const QString &location, const QString &os, const QString &status, QObject *parent):
    QObject(parent),m_username(username),m_systemname(systemname), m_ip(ip), m_location(location), m_os(os), m_status(status)
{

}

QString Client::id() const
{
    return m_id;
}


QString Client::username() const
{
    return m_username;   
}

QString Client::systemname() const
{
    return m_systemname;
}

QString Client::ip() const
{
    return m_ip;
}


QString Client::location() const
{
    return m_location;
}

QString Client::os() const
{
    return m_os;
}

QString Client::status() const
{
    return m_status;
}

void Client::setId(QString id)
{
    if (m_id == id)
        return;

    m_id = id;
    emit idChanged(m_id);
}

void Client::setUsername(QString username)
{
    if (m_username == username)
        return;

    m_username = username;
    emit usernameChanged(m_username);
}

void Client::setSystemname(QString systemname)
{
    if (m_systemname == systemname)
        return;

    m_systemname = systemname;
    emit systemnameChanged(m_systemname);
}

void Client::setIp(QString ip)
{
    if (m_ip == ip)
        return;

    m_ip = ip;
    emit ipChanged(m_ip);
}

void Client::setLocation(QString location)
{
    if (m_location == location)
        return;

    m_location = location;
    emit locationChanged(m_location);
}

void Client::setOs(QString os)
{
    if (m_os == os)
        return;

    m_os = os;
    emit ipChanged(m_os);
}

void Client::setStatus(QString status)
{
    if (m_status == status)
        return;

    m_status = status;
    emit statusChanged(status);
}
