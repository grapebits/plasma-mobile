/*
    Copyright 2012 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#ifndef METADATATIMELINEMODEL_H
#define METADATATIMELINEMODEL_H

#include "abstractmetadatamodel.h"

#include <QDate>

#include <Nepomuk/Query/Query>
#include <Nepomuk/Query/Result>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Resource>


namespace Nepomuk {
    class ResourceWatcher;
}

class QDBusServiceWatcher;
class QTimer;

class MetadataTimelineModel : public AbstractMetadataModel
{
    Q_OBJECT

    Q_PROPERTY(Level level READ level WRITE setLevel NOTIFY levelChanged)

public:
    enum Roles {
        YearRole = Qt::UserRole + 1,
        MonthRole = Qt::UserRole + 2,
        DayRole = Qt::UserRole + 3,
        CountRole = Qt::UserRole + 4
    };

    enum Level {
        Year = 0,
        Month,
        Day
    };
    Q_ENUMS(Level)

    MetadataTimelineModel(QObject *parent = 0);
    ~MetadataTimelineModel();

    virtual int count() const {return m_results.count();}


    void setLevel(Level level);
    Level level() const;


    //Reimplemented
    QVariant data(const QModelIndex &index, int role) const;

Q_SIGNALS:
   void levelChanged();

protected Q_SLOTS:
    void newEntries(const QList< Nepomuk::Query::Result > &entries);
    void entriesRemoved(const QList<QUrl> &urls);
    virtual void doQuery();
    void finishedListing();

private:
    Nepomuk::Query::QueryServiceClient *m_queryClient;
    QVector<QHash<Roles, int> > m_results;
    QVariantList m_categories;
    QTimer *m_queryTimer;
    Level m_level;
};

#endif
