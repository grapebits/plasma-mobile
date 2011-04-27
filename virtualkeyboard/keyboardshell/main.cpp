/*
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2009 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as
 *   published by the Free Software Foundation; either version 2,
 *   or (at your option) any later version.
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

#include <KApplication>
#include <KAboutData>
#include <KCmdLineArgs>
#include <KLocale>
#include <KIcon>

#include "plasmaapp.h"

static const char description[] = I18N_NOOP( "Shell used to load Plasma widgets as stand-alone applications." );
static const char version[] = "0.1";

extern "C"
KDE_EXPORT int kdemain(int argc, char **argv)
{
    KAboutData aboutData("plasma-keyboardcontainer", 0, ki18n("Container for on screen keyboard"),
                         version, ki18n(description), KAboutData::License_GPL,
                         ki18n("Copyright 2006-2009, The KDE Team"));
    aboutData.addAuthor(ki18n("Marco Martin"),
                        ki18n("Author and maintainer"),
                        "notmart@gmail.com");

    KCmdLineArgs::init(argc, argv, &aboutData);

    PlasmaApp *app = PlasmaApp::self();
    QApplication::setWindowIcon(KIcon("input-keyboard"));
    int rc = app->exec();
    delete app;
    return rc;
}
