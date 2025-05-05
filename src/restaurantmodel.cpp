#include "restaurantmodel.h"

RestaurantModel::RestaurantModel(QObject *parent) : QAbstractListModel(parent)
{
    m_networkManager = new QNetworkAccessManager(this);
    connect(m_networkManager, &QNetworkAccessManager::finished,
            this, [this](QNetworkReply *reply) { this->onNetworkReply(reply); });

    m_selectedDate = QDate::currentDate();
    m_networkErrorString = nullptr;
}

int RestaurantModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_restaurants.size();
}

QVariant RestaurantModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_restaurants.size())
        return QVariant();

    const Restaurant &restaurant = m_restaurants[index.row()];

    switch (role) {
    case NameRole:
        return restaurant.name;
    case CampusRole:
        return restaurant.campus;
    case CityRole:
        return restaurant.city;
    case ProviderRole:
        return restaurant.provider;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> RestaurantModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[CampusRole] = "campus";
    roles[CityRole] = "city";
    roles[ProviderRole] = "provider";
    return roles;
}

void RestaurantModel::fetchRestaurants()
{
    // Reset restaurant list to trigger loader
    m_restaurants.clear();
    emit restaurantsLoaded();
    m_networkErrorString = nullptr;
    emit networkError();

    QUrl url("https://ouf.fi/api/menu?campus=Linnanmaa&city=Oulu");
    QNetworkRequest request(url);
    m_networkManager->get(request);
}

/**
 * @brief The next 5 dates available in inverted order (oldest date last)
 */
QVariantList RestaurantModel::getAvailableDates() const
{
    QVariantList result;
    QSet<QDate> uniqueDates; // Use a set to avoid duplicates

    // Collect all unique dates from all restaurants
    for (const Restaurant &restaurant : m_restaurants) {
        for (const Menu &menu : restaurant.menu) {
            uniqueDates.insert(menu.date);
        }
    }

    // Convert set to sorted list
    QList<QDate> dateList = uniqueDates.values();
    std::sort(dateList.begin(), dateList.end(), std::greater<QDate>());

    if (dateList.size() > 5) dateList = dateList.mid(dateList.size() - 5, 5);

    // Convert to QVariantList for QML
    for (int i = 0; i < dateList.size(); i++) {
        result.append(QVariant(dateList[i]));
    }

    return result;
}

void RestaurantModel::setSelectedDate(const QDate &date)
{
    if (m_selectedDate != date) {
        m_selectedDate = date;
        emit selectedDateChanged();
    }
}

QDate RestaurantModel::getSelectedDate() const
{
    return m_selectedDate;
}

QString RestaurantModel::getNetworkError() const
{
    if(m_networkErrorString == nullptr)
        return "";
    return m_networkErrorString;
}

void RestaurantModel::onNetworkReply(QNetworkReply *reply)
{
    if (reply->error()) {
        const auto err = reply->errorString();
        m_networkErrorString = err;
        emit networkError();
        qDebug() << "Network error:" << err;
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(data);

    if (jsonDoc.isNull()) {
        qDebug() << "Failed to parse JSON response";
        reply->deleteLater();
        return;
    }

    if (!jsonDoc.isArray()) {
        qDebug() << "JSON response is not an array";
        reply->deleteLater();
        return;
    }

    QJsonArray jsonArray = jsonDoc.array();
    qDebug() << "Parsed JSON array with" << jsonArray.size() << "restaurants";

    beginResetModel();
    m_restaurants.clear();

    for (const QJsonValue &value : jsonArray) {
        QJsonObject obj = value.toObject();

        Restaurant restaurant;
        restaurant.name = obj["name"].toString();
        restaurant.url = obj["url"].toString();
        restaurant.campus = obj["campus"].toString();
        restaurant.city = obj["city"].toString();
        restaurant.provider = obj["provider"].toString();

        qDebug() << "Received restaurant " << restaurant.name;

        // Parse menu
        QJsonArray menuArray = obj["menu"].toArray();
        for (const QJsonValue &menuValue : menuArray) {
            QJsonObject menuObj = menuValue.toObject();

            Menu menu;
            menu.date = QDate::fromString(menuObj["date"].toString(), Qt::ISODate);

            // Parse English categories
            QJsonArray enArray = menuObj["en"].toArray();
            for (const QJsonValue &categoryValue : enArray) {
                QJsonObject categoryObj = categoryValue.toObject();

                MenuCategory category;
                category.name = categoryObj["name"].toString();

                QJsonArray itemsArray = categoryObj["items"].toArray();
                for (const QJsonValue &itemValue : itemsArray) {
                    QJsonObject itemObj = itemValue.toObject();

                    MenuItem item;
                    item.name = itemObj["name"].toString();
                    item.diets = itemObj["diets"].toString();
                    item.ingredients = itemObj["ingredients"].toString();

                    category.items.append(item);
                }

                menu.enCategories.append(category);
            }

            // Parse Finnish categories
            QJsonArray fiArray = menuObj["fi"].toArray();
            for (const QJsonValue &categoryValue : fiArray) {
                QJsonObject categoryObj = categoryValue.toObject();

                MenuCategory category;
                category.name = categoryObj["name"].toString();

                QJsonArray itemsArray = categoryObj["items"].toArray();
                for (const QJsonValue &itemValue : itemsArray) {
                    QJsonObject itemObj = itemValue.toObject();

                    MenuItem item;
                    item.name = itemObj["name"].toString();
                    item.diets = itemObj["diets"].toString();
                    item.ingredients = itemObj["ingredients"].toString();

                    category.items.append(item);
                }

                menu.fiCategories.append(category);
            }

            restaurant.menu.append(menu);
        }

        m_restaurants.append(restaurant);
    }

    QVariantList availableDates = getAvailableDates();
    if (!availableDates.isEmpty()) {
        setSelectedDate(availableDates.last().toDate());
    }

    qDebug() << "Model populated with" << m_restaurants.size() << "restaurants";
    endResetModel();
    emit restaurantsLoaded();
    emit selectedDateChanged();
    reply->deleteLater();
}

QVariantMap RestaurantModel::getRestaurantMenu(int index) const
{
    QVariantMap result;
    if (index < 0 || index >= m_restaurants.size())
        return result;

    const Restaurant &restaurant = m_restaurants[index];

    result["name"] = restaurant.name;

    // Convert menu to QVariantList for QML
    QVariantMap menuMap;
    for (const Menu &menu : restaurant.menu) {
        if (menu.date == m_selectedDate) {
            menuMap["date"] = menu.date;

            // Convert English categories
            QVariantList enList;
            for (const MenuCategory &category : menu.enCategories) {
                QVariantMap categoryMap;
                categoryMap["name"] = category.name;

                QVariantList itemsList;
                for (const MenuItem &item : category.items) {
                    QVariantMap itemMap;
                    itemMap["name"] = item.name;
                    itemMap["diets"] = item.diets;
                    itemMap["ingredients"] = item.ingredients;
                    itemsList.append(itemMap);
                }

                categoryMap["items"] = itemsList;
                enList.append(categoryMap);
            }
            menuMap["en"] = enList;

            // Convert Finnish categories
            QVariantList fiList;
            for (const MenuCategory &category : menu.fiCategories) {
                QVariantMap categoryMap;
                categoryMap["name"] = category.name;

                QVariantList itemsList;
                for (const MenuItem &item : category.items) {
                    QVariantMap itemMap;
                    itemMap["name"] = item.name;
                    itemMap["diets"] = item.diets;
                    itemMap["ingredients"] = item.ingredients;
                    itemsList.append(itemMap);
                }

                categoryMap["items"] = itemsList;
                fiList.append(categoryMap);
            }
            menuMap["fi"] = fiList;

            break; // We found the menu for selected date, no need to continue
        }
    }

    result["menu"] = menuMap;
    return result;
}
