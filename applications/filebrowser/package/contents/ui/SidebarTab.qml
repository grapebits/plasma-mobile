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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.1
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore


Item {
    id: root
    property bool checked: false
    property alias text: tabLabel.text
    width: tabLabel.height + frame.margins.left + frame.margins.right
    height: tabLabel.width + frame.margins.top + frame.margins.bottom

    PlasmaCore.FrameSvgItem {
        id: frame
        imagePath: "dialogs/background"
        enabledBorders: "LeftBorder|TopBorder|BottomBorder"
        anchors {
            fill: parent
            leftMargin: checked? -10 : 0
        }

        PlasmaComponents.Label {
            id: tabLabel
            x: parent.margins.left
            y: parent.margins.top + width
            transformOrigin: Item.Center
            transform: Rotation {
                angle: -90
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.checked) {
                    root.parent.uncheckAll()
                } else {
                    root.checked = true
                }
            }
        }
    }
}