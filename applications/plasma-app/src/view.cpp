/***************************************************************************
 *                                                                         *
 *   Copyright 2011-2014 Sebastian Kügler <sebas@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "view.h"

#include <QDebug>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickItem>

#include <Plasma/Package>
#include <Plasma/PluginLoader>

#include <KDeclarative/KDeclarative>
#include <KLocalizedString>


View::View(const QString &module, const QString &package, QWindow *parent)
    : QQuickView(parent)
{
    setResizeMode(QQuickView::SizeRootObjectToView);
    QQuickWindow::setDefaultAlphaBuffer(true);

    setIcon(QIcon::fromTheme("preferences-desktop")); // FIXME read those from metadata
    setTitle(i18n("Plasma App"));

    KDeclarative::KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    //binds things like kconfig and icons
    kdeclarative.setupBindings();

    m_package = Plasma::PluginLoader::self()->loadPackage("Plasma/Generic");
    if (!package.isEmpty()) {
        m_package.setPath(package);
        setIcon(QIcon::fromTheme(m_package.metadata().icon()));
        setTitle(m_package.metadata().name());
    } else {
        qWarning() << "No package specified";
    }

    const QString qmlFile = m_package.filePath("mainscript");
    qDebug() << "mainscript: " << QUrl::fromLocalFile(m_package.filePath("mainscript"));
    setSource(QUrl::fromLocalFile(m_package.filePath("mainscript")));
    show();

    onStatusChanged(status());

    connect(this, &QQuickView::statusChanged,
            this, &View::onStatusChanged);
}

View::~View()
{
}

void View::updateStatus()
{
    onStatusChanged(status());
}

void View::onStatusChanged(QQuickView::Status status)
{
    //qDebug() << "onStatusChanged";
    if (status == QQuickView::Ready) {

    } else if (status == QQuickView::Error) {
        foreach (const QQmlError &e, errors()) {
            qWarning() << "error in QML: " << e.toString() << e.description();
        }
    } else if (status == QQuickView::Loading) {
        //qDebug() << "Loading.";
    }
}
