/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef PLASMAINPUTCONTEXTPLUGIN_H
#define PLASMAINPUTCONTEXTPLUGIN_H

#include <QInputContextPlugin>

class PlasmaInputContextPlugin: public QInputContextPlugin
{
    Q_OBJECT

public:
    PlasmaInputContextPlugin(QObject *parent = 0);
    virtual ~PlasmaInputContextPlugin();

    QInputContext *create(const QString &key);
    QString description(const QString &key);
    QString displayName(const QString &key);
    QStringList keys() const;
    QStringList languages(const QString &key);
};

#endif