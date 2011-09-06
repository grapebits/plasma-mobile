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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

Rectangle {
    id: quickBrowserBar

    function setCurrentIndex(index)
    {
        thumbnailsView.positionViewAtIndex(index, ListView.Center)
        thumbnailsView.currentIndex = index
    }

    Behavior on y {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
    z: 9999
    color: Qt.rgba(1, 1, 1, 0.7)

    anchors {
        left: parent.left
        right: parent.right
    }

    height: 65
    PlasmaCore.DataSource {
        id: previewSource
        engine: "org.kde.preview"
    }
    ListView {
        id: thumbnailsView
        spacing: 1
        anchors {
            fill: parent
            topMargin: 1
        }
        orientation: ListView.Horizontal
        model: filterModel

        delegate: QImageItem {
            id: delegate
            z: index==thumbnailsView.currentIndex?200:0
            scale: index==thumbnailsView.currentIndex?1.4:1
            Behavior on scale {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
            width: height*1.6
            height: thumbnailsView.height
            image: previewSource.data[url]["thumbnail"]
            Component.onCompleted: {
                previewSource.connectSource(url)
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    thumbnailsView.currentIndex = index
                    viewer.setCurrentIndex(index)
                }
            }
        }
    }
}