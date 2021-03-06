/***************************************************************************
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *   Copyright 2010 Marco Martin <mart@kde.org>                            *
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

import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.kquickcontrolsaddons 2.0

Item {
    id: activityPanel
    anchors {
        topMargin: 50
        top: parent.top
        bottom: parent.bottom
    }

    width: 400

    //FIXME: this state change sequence at startup seems to fix a correct binding to parent size changes
    state: "dragging"
    x: parent.width

    Component {
        id: activitySwitcherMain
        ActivityManager {}
    }

    Component.onCompleted:  {
        activityPanel.state = "hidden"
        activityPanel.switcher = activitySwitcherMain.createObject(hintregion);
    }

    property Item switcher
    onStateChanged: {
        if (!switcher) {
            return
        }

        if (state == "hidden") {
            switcher.state = "Passive"
        } else if (switcher.state == "Passive") {
            switcher.state = "Normal"
        }
    }

    //Uses a MouseEventListener instead of a MouseArea to not block any mouse event
    MouseEventListener {
        id: hintregion;

        anchors.fill: parent
        anchors.leftMargin: -60

        property int startX
        property int startMouseX
        property string previousState
        onPressed: {
            startMouseX = mouse.screenX
            startX = activityPanel.x
            hideTimer.running = false
            previousState = activityPanel.state
            activityPanel.state = "dragging"
        }

        onPositionChanged: {
            activityPanel.x = Math.max(startX + (mouse.screenX - startMouseX),
                                    activityPanel.parent.width - activityPanel.width)
            hideTimer.running = false

        }

        onReleased: {
            if ((previousState == "hidden" && activityPanel.x < activityPanel.parent.width - activityPanel.width/3) ||
                (previousState == "show" && activityPanel.x < activityPanel.parent.width - activityPanel.width/3*2)) {
                    activityPanel.state = "show"
                    if (activityPanel.switcher.state != "AcceptingInput") {
                        hideTimer.restart()
                    }
                } else {
                    activityPanel.state = "hidden"
                }
        }

        PlasmaCore.FrameSvgItem {
            id: hint
            x: 20
            width: 60
            height: 80
            anchors.verticalCenter: parent.verticalCenter
            imagePath: "widgets/background"
            PlasmaCore.SvgItem {
                width:22
                height:22
                svg: PlasmaCore.Svg {
                    imagePath: Qt.resolvedUrl("plasmapackage:/images/panel-icons.svgz")
                }
                elementId: "activities"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: hint.margins.left
                }
            }
            MouseArea {
                anchors.fill: parent
                property int startX
                onPressed: startX = activityPanel.x
                onClicked: {
                    if (Math.abs(startX - activityPanel.x) < 8) {
                        activityPanel.state = activityPanel.x < activityPanel.parent.width?"hidden":"show"
                    }
                }
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 4000;
        running: false;
        onTriggered:  {
            if (activityPanel.switcher.state != "AcceptingInput") {
                activityPanel.state = "hidden"
            }
        }
    }

    states: [
        State {
            name: "show";
            PropertyChanges {
                target: activityPanel;
                x: parent.width - width;
            }
            PropertyChanges {
                target: hideTimer;
                running: true
            }
        },
        State {
            name: "hidden";
            PropertyChanges {
                target: activityPanel;
                x: parent.width;
            }
        },
        State {
            name: "dragging"
            PropertyChanges {
                target: activityPanel;
                x: activityPanel.x;
                y: activityPanel.y;

            }
        }
    ]

    transitions: [
        Transition {
            from: "show";
            to: "hidden";
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        targets: activityPanel;
                        properties: "x";
                        duration: 500;
                        easing.type: "InOutCubic";
                    }
                }
            }
        },
        Transition {
            from: "hidden";
            to: "show";
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        targets: activityPanel;
                        properties: "x";
                        duration: 400;
                        easing.type: "InOutCubic";
                    }
                }
            }
        },
        Transition {
            from: "dragging";
            to: "*";
            NumberAnimation {
                properties: "x,y";
                easing.type: "OutQuad";
                duration: 400;
            }
        }
    ]

}
