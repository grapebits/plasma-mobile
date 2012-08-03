/*
 * Copyright 2012 Marco Martin <mart@kde.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License version 2 as
 * published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef ALARMCONTAINER_H
#define ALARMCONTAINER_H

// plasma
#include <Plasma/DataContainer>

// KAlarmCal
#include <kalarmcal/kaevent.h>



class AlarmContainer : public Plasma::DataContainer
{
    Q_OBJECT

public:
    AlarmContainer(const QString &name,
                   const KAlarmCal::KAEvent &alarm,
                   QObject *parent = 0);
    ~AlarmContainer();

private:
    KAlarmCal::KAEvent m_alarmEvent;
};

#endif // ALARMCONTAINER_H
