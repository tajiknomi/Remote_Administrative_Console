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
