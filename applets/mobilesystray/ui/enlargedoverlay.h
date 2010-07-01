/*
 *   Copyright 2008 Lim Yuen Hoe <yuenhoe@hotmail.com>
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

#ifndef OVERLAYTOOLBOX_H
#define OVERLAYTOOLBOX_H

#include <KAction>
#include <QGraphicsWidget>
#include <QGraphicsSceneResizeEvent>
#include <QGraphicsSceneMouseEvent>

#include <Plasma/Label>
#include <Plasma/FrameSvg>
#include <Plasma/Applet>

#include "../core/task.h"

namespace Plasma
{
  class Applet;
}

namespace SystemTray
{

class EnlargedOverlay : public Plasma::Applet
{
    Q_OBJECT

public:
    EnlargedOverlay(QList<Task*> tasks, QSize containerSize, QGraphicsWidget *parent = 0);
    ~EnlargedOverlay();

protected:
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option,
               QWidget *widget = 0);
    void resizeEvent(QGraphicsSceneResizeEvent *event);
private:
    Plasma::FrameSvg m_background;
};

}

#endif
