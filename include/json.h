#pragma once

#include <vector>
#include <QString>

// data (vector of string) -----> json
QString to_json(const QVector<QString>& data);

// json -----> data (vector of string)
std::vector<QString> from_json(const QString& jsonData);

// Extract <value> from json using <key>
QString json_ExtractValue(const QString& jsonData, const QString& key);

// Insert a key-value pair into an existing JSON string
QString json_AppendKeyValue(const QString& jsonData, QString& key, const QString& value);

// Remove a key-value pair from JSON string
QString json_RemoveValue(const QString& jsonData, const QString& key);
