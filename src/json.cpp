#include <QString>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>


QString to_json(const QVector<QString>& data) {
    QJsonObject jsonObject;

    if (data.size() % 2 == 0) {
        for (int i = 0; i < data.size(); i += 2) {
            const QString& key = data[i];
            const QString& value = data[i + 1];

            jsonObject.insert(key, value);
        }
    }

    // Convert the JSON object to a QJsonDocument
    QJsonDocument jsonDocument(jsonObject);

    return jsonDocument.toJson(QJsonDocument::Compact);
}

QVector<QString> from_json(const QString& jsonData) {
    QJsonDocument jsonDocument = QJsonDocument::fromJson(jsonData.toUtf8());

    if (jsonDocument.isNull() || !jsonDocument.isObject()) {
        // Handle JSON parse error here
        return {};
    }

    QVector<QString> parsedData;

    QJsonObject jsonObject = jsonDocument.object();
    for (auto it = jsonObject.begin(); it != jsonObject.end(); ++it) {
        const QString key = it.key();
        const QJsonValue value = it.value();

        if (value.isString()) {
            parsedData.append(key);
            parsedData.append(value.toString());
        }
    }

    return parsedData;
}

QString json_ExtractValue(const QString& jsonData, const QString& key) {

    QJsonDocument jsonDocument = QJsonDocument::fromJson(jsonData.toUtf8());
    if (jsonDocument.isNull() || !jsonDocument.isObject()) {
        qDebug() << "Invalid JSON format. Expected an object.";
        return "";
    }
    QJsonObject jsonObject = jsonDocument.object();
    if (!jsonObject.contains(key)) {
        //qDebug() << key << " not found: " << key;
        return "";
    }
    QJsonValue value = jsonObject.value(key);
    if (value.isObject()) {
        QJsonObject nestedObject = value.toObject();
        QJsonDocument doc(nestedObject);
        QString jsonString = doc.toJson(QJsonDocument::Compact);
        return jsonString;
    }
    return value.toString();
}

QString json_AppendKeyValue(const QString& jsonData, const QString& key, const QString& value) {
    QJsonDocument jsonDocument = QJsonDocument::fromJson(jsonData.toUtf8());

    if (jsonDocument.isNull() || !jsonDocument.isObject()) {
        // qDebug() << "Invalid JSON format. Expected an object.";
        return jsonData;
    }

    QJsonObject jsonObject = jsonDocument.object();

    jsonObject.insert(key, QJsonValue(value));

    QJsonDocument newJsonDocument(jsonObject);

    return newJsonDocument.toJson(QJsonDocument::Compact);
}

QString json_RemoveValue(const QString& jsonData, const QString& key) {
    QJsonDocument jsonDocument = QJsonDocument::fromJson(jsonData.toUtf8());

    if (jsonDocument.isNull() || !jsonDocument.isObject()) {
        qDebug() << "Invalid JSON format. Expected an object.";
        return jsonData;
    }

    QJsonObject jsonObject = jsonDocument.object();

    if (!jsonObject.contains(key)) {
        qDebug() << "Key not found: " << key;
        return jsonData;
    }

    jsonObject.remove(key);

    QJsonDocument newJsonDocument(jsonObject);

    return newJsonDocument.toJson(QJsonDocument::Compact);
}
