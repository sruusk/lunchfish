#ifndef RESTAURANTMODEL_H
#define RESTAURANTMODEL_H

#include <QAbstractListModel>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVector>
#include <QDateTime>

struct MenuItem {
    QString name;
    QString diets;
    QString ingredients;
};

struct MenuCategory {
    QString name;
    QVector<MenuItem> items;
};

struct Menu {
    QDate date;
    QVector<MenuCategory> enCategories;
    QVector<MenuCategory> fiCategories;
};

struct Restaurant {
    QString name;
    QString url;
    QString campus;
    QString city;
    QString provider;
    QVector<Menu> menu;
};

class RestaurantModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum RestaurantRoles {
        NameRole = Qt::UserRole + 1,
        CampusRole,
        CityRole,
        ProviderRole
    };

    explicit RestaurantModel(QObject *parent = nullptr);

    // QAbstractListModel implementation
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Custom methods
    Q_INVOKABLE void fetchRestaurants();
    Q_INVOKABLE QVariantMap getRestaurantMenu(int index) const;
    Q_PROPERTY(int count READ rowCount NOTIFY restaurantsLoaded)

    Q_INVOKABLE QVariantList getAvailableDates() const;
    Q_INVOKABLE void setSelectedDate(const QDate &date);
    Q_INVOKABLE QDate getSelectedDate() const;
    Q_PROPERTY(QDate selectedDate READ getSelectedDate WRITE setSelectedDate NOTIFY selectedDateChanged)

signals:
    void restaurantsLoaded();
    void selectedDateChanged();

private slots:
    void onNetworkReply(QNetworkReply *reply);

private:
    QVector<Restaurant> m_restaurants;
    QNetworkAccessManager *m_networkManager;
    QDate m_selectedDate;
};

#endif // RESTAURANTMODEL_H
