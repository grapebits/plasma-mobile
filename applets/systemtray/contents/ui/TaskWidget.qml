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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1 as QtExtra

Item  {
    id: taskIcon
    width: Math.min(main.width, main.height)
    height: width
    visible: main.state == "active" || Status != "Passive"

    PlasmaCore.Svg{
        id: iconSvg
        imagePath: "icons/"+String(IconName).split('-')[0]
        Component.onCompleted: {
            var hasSvg = iconSvg.hasElement(IconName)
            normalIcon.visible = !hasSvg
            svgItemIcon.visible = hasSvg
        }
    }

    QtExtra.QIconItem {
        id: normalIcon
        anchors.fill: parent
        icon: Icon
    }
    PlasmaCore.SvgItem {
        id: svgItemIcon
        anchors.fill: parent
        svg: iconSvg
        elementId: IconName
    }

    MouseArea {
        anchors.fill: taskIcon
        onClicked: {
            print(iconSvg.hasElement(IconName))
            var service = statusNotifierSource.serviceForSource(DataEngineSource)
            var operation = service.operationDescription("Activate")
            operation.x = parent.x
            operation.y = parent.y
            service.startOperationCall(operation)
        }
    }
}