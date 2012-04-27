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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

Item {
    id: root
    //+1: switch to next image on mouse release
    //-1: switch to previous image on mouse release
    //0: do nothing
    property int delta
    //if true when released will switch the delegate
    property bool doSwitch: false

    property alias source: mainImage.source
    property string label: model["label"]

    SequentialAnimation {
        id: zoomAnim
        function zoom(factor)
        {
            if (factor < 1 && mainFlickable.contentWidth < mainFlickable.width && mainFlickable.contentHeight < mainFlickable.height) {
                return
            } else if (factor > 1 && (mainFlickable.contentWidth > mainFlickable.width*8 && mainFlickable.contentHeight > mainFlickable.height*8)) {
                return
            }

            contentXAnim.to = Math.max(0, Math.min(mainFlickable.contentWidth-mainFlickable.width, (mainFlickable.contentX * factor)))
            contentYAnim.to = Math.max(0, Math.min(mainFlickable.contentHeight-mainFlickable.height, (mainFlickable.contentY * factor)))
            imageWidthAnim.to = mainImage.width * factor
            imageHeightAnim.to = mainImage.height * factor
            zoomAnim.running = true
        }

        ParallelAnimation {
            NumberAnimation {
                id: imageWidthAnim
                duration: 250
                easing.type: Easing.InOutQuad
                target: mainImage
                property: "width"
            }
            NumberAnimation {
                id: imageHeightAnim
                duration: 250
                easing.type: Easing.InOutQuad
                target: mainImage
                property: "height"
            }
            NumberAnimation {
                id: contentXAnim
                duration: 250
                easing.type: Easing.InOutQuad
                target: mainFlickable
                property: "contentX"
            }
            NumberAnimation {
                id: contentYAnim
                duration: 250
                easing.type: Easing.InOutQuad
                target: mainFlickable
                property: "contentY"
            }
        }
        ScriptAction {
            script: mainFlickable.returnToBounds()
        }
    }

    Connections {
        target: viewerPage
        onZoomIn: {
            zoomAnim.zoom(1.4)
        }
        onZoomOut: {
            zoomAnim.zoom(0.6)
        }
    }

    Flickable {
        id: mainFlickable
        anchors.fill: parent
        width: parent.width
        height: parent.height
        contentWidth: imageMargin.width
        contentHeight: imageMargin.height

        onContentXChanged: {
            if (atXBeginning && contentX < 0) {
                root.delta = -1
                root.doSwitch = (contentX < -mainFlickable.width/3)
            } else if (atXEnd) {
                root.delta = +1
                root.doSwitch = (contentX + mainFlickable.width - contentWidth > mainFlickable.width/3)
            } else {
                root.delta = 0
                root.doSwitch = false
            }
        }

        Rectangle {
            id: imageMargin
            color: "black"
            width: Math.max(mainFlickable.width+1, mainImage.width)
            height: Math.max(mainFlickable.height, mainImage.height)
            PinchArea {
                anchors.fill: parent

                property real startWidth
                property real startHeight
                property real startY
                property real startX
                onPinchStarted: {
                    startWidth = mainImage.width
                    startHeight = mainImage.height
                    startY = pinch.center.y
                    startX = pinch.center.x
                }
                onPinchUpdated: {
                    var deltaWidth = mainImage.width < imageMargin.width ? ((startWidth * pinch.scale) - mainImage.width) : 0
                    var deltaHeight = mainImage.height < imageMargin.height ? ((startHeight * pinch.scale) - mainImage.height) : 0
                    mainImage.width = startWidth * pinch.scale
                    mainImage.height = startHeight * pinch.scale

                    mainFlickable.contentY += pinch.previousCenter.y - pinch.center.y + startY * (pinch.scale - pinch.previousScale) - deltaHeight

                    mainFlickable.contentX += pinch.previousCenter.x - pinch.center.x + startX * (pinch.scale - pinch.previousScale) - deltaWidth
                }

                Image {
                    id: mainImage

                    asynchronous: true
                    anchors.centerIn: parent
                    width: mainFlickable.contentWidth
                    height: mainFlickable.contentHeight
                    onSourceChanged: sourceSize = undefined
                    onStatusChanged: {
                        if (status != Image.Ready) {
                            return
                        }

                        loadingText.visible = false

                        // do not try to load an empty mainImage.source or it will mess up with mainImage.scale
                        // and make the next valid url fail to load.
                        if (mainFlickable.parent.width < 1 || mainFlickable.parent.height < 1) {
                            return
                        }

                        var ratio = sourceSize.width/sourceSize.height

                        if (sourceSize.width > sourceSize.height) {
                            mainImage.width = Math.min(mainFlickable.width + 1, sourceSize.width)
                            mainImage.height = mainImage.width / ratio
                        } else {
                            mainImage.height = Math.min(mainFlickable.height, sourceSize.height)
                            mainImage.width = mainImage.height * ratio
                        }
                        if (mainImage.sourceSize.width > mainImage.sourceSize.height && mainImage.sourceSize.width > mainFlickable.width) {
                            mainImage.sourceSize.width = mainFlickable.width
                            mainImage.sourceSize.height = mainImage.sourceSize.width / ratio
                        } else if (mainImage.sourceSize.height > mainImage.sourceSize.width && mainImage.sourceSize.height > mainFlickable.height) {
                            mainImage.sourceSize.width = mainFlickable.height * ratio
                            mainImage.sourceSize.height = mainFlickable.height
                        }
                    }
                }

                PlasmaExtras.Title {
                    id: loadingText
                    anchors.centerIn: mainImage
                    text: i18n("Loading...")
                    color: "gray"
                }
            }
            Image {
                z: -1
                source: "image://appbackgrounds/shadow-left"
                fillMode: Image.TileVertically
                anchors {
                    right: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: -1
                }
            }
            Image {
                z: -1
                source: "image://appbackgrounds/shadow-right"
                fillMode: Image.TileVertically
                anchors {
                    left: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: -1
                }
            }
        }
    }
}