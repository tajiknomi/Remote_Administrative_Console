#ifndef CLIENT_H
#define CLIENT_H

#include <QObject>

class Client : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString systemname READ systemname WRITE setSystemname NOTIFY systemnameChanged)
    Q_PROPERTY(QString ip READ ip WRITE setIp NOTIFY ipChanged)
    Q_PROPERTY(QString location READ location WRITE setLocation NOTIFY locationChanged)
    Q_PROPERTY(QString os READ os WRITE setOs NOTIFY osChanged)
    Q_PROPERTY(QString status READ status WRITE setStatus NOTIFY statusChanged)

public:
    explicit Client(QObject *parent = nullptr);
    Client(const QString &username,
           const QString &systemname,
           const QString &ip,
           const QString &location,
           const QString &os,
           const QString &status,
           QObject * parent = nullptr);

    QString id() const;
    QString username() const;
    QString systemname() const;
    QString ip() const;
    QString location() const;
    QString os() const;
    QString status() const;

    void setId(QString id);
    void setUsername(QString username);
    void setSystemname(QString systemname);
    void setIp(QString ip);
    void setLocation(QString location);
    void setOs(QString os);
    void setStatus(QString status);

signals:
    void idChanged(QString id);
    void usernameChanged(QString username);
    void systemnameChanged(QString username);
    void ipChanged(QString username);
    void locationChanged(QString username);
    void osChanged(QString username);
    void statusChanged(QString username);

private:
    QString m_id;
    QString m_username;
    QString m_systemname;
    QString m_ip;
    QString m_location;
    QString m_os;
    QString m_status;

};

#endif // PERSON_H
