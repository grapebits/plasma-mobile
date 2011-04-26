/***************************************************************************
 *   Copyright 2011 by Davide Bettio <davide.bettio@kdemail.net>           *
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

#include "mobiledolphin.h"

#include <QDeclarativeContext>
#include <QDeclarativeComponent>
#include <QDeclarativeItem>
#include <kdeclarative.h>

#include <kdirmodel.h>
#include <kdirlister.h>
#include <kdebug.h>

#include <QApplication>
#include <KStandardAction>
#include <KStandardDirs>
#include <QAction>
#include <KAction>

MobileDolphin::MobileDolphin(KUrl url)
{
    KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    kdeclarative.setupBindings();

    lister = new KDirLister;
    lister->openUrl(url);
    files = new KDeclarativeDirModel;
    files->setDirLister(lister);

    rootContext()->setContextProperty("myModel", files);
    rootContext()->setContextProperty("directory", lister->url().prettyUrl());
    setSource(QUrl::fromLocalFile(KStandardDirs::locate("data", "mobiledolphin/ui/mobiledolphin.qml")));
    connect(rootObject(), SIGNAL(fileClicked(QString)), this, SLOT(changeDir(QString)));
    connect(rootObject(), SIGNAL(fileShowContextualMenu(QString)), this, SLOT(showContextualMenu(QString)));
}

void MobileDolphin::changeDir(QString name)
{
    KUrl url = lister->url();
    url.cd(name);
    rootContext()->setContextProperty("directory", url.prettyUrl());
    lister->openUrl(url);
}

void MobileDolphin::showContextualMenu(QString name)
{
    QList<QObject *> actions;
    actions.append(KStandardAction::copy(0, 0, 0));
    actions.append(KStandardAction::paste(0, 0, 0));
    actions.append(KStandardAction::cut(QApplication::instance(), SLOT(quit()), 0));

    QDeclarativeContext *newContext = new QDeclarativeContext(rootContext());
    QDeclarativeComponent component(engine(), QUrl::fromLocalFile(KStandardDirs::locate("data", "mobiledolphin/ui/ActionsMenu.qml")));
    newContext->setContextProperty("actionsModel", QVariant::fromValue(actions));
    QObject *myObject = component.create(newContext);
    QDeclarativeItem *item = static_cast<QDeclarativeItem *>(myObject);
    scene()->addItem(item);
    item->setZValue(100);
}

#include "mobiledolphin.h"
