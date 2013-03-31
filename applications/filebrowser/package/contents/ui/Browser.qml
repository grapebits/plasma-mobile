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
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.draganddrop 1.0
import org.kde.qtextracomponents 0.1


MobileComponents.SplitDrawer {
    id: resourceBrowser
    objectName: "resourceBrowser"
    property string currentUdi
    anchors {
        fill: parent
        topMargin: toolBar.height
    }


    open: true
    property bool hasItems: metadataModel.count > 0 || dirModel.count > 0
    onHasItemsChanged: mainLoader.visible = true

    PlasmaExtras.ConditionalLoader {
        id: mainLoader
        when: hasItems
        visible: false
        anchors.fill: parent
        source: Qt.resolvedUrl("BrowserFrame.qml")
        onItemChanged: {
            if (item) {
                resourceBrowser.page = mainLoader
            }
        }
    }

    tools: PlasmaExtras.ConditionalLoader {
        when: hasItems
        width: item.width
        height: item.height
        source: Qt.resolvedUrl("ToolBar.qml")
    }

    drawer: Item {
        id: sidebar
        clip: false

        anchors.fill: parent

        Item {
            anchors.fill: parent
            clip: false
            PlasmaComponents.TabGroup {
                id: sidebarTabGroup
                width: fileBrowserRoot.width/4 - theme.defaultFont.mSize.width * 2
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    bottomMargin: 0
                    //topMargin: toolBar.height
                    leftMargin: theme.defaultFont.mSize.width * 2
                    rightMargin: theme.defaultFont.mSize.width
                }
                CategorySidebar {
                    id: categorySidebar
                }
                PlasmaExtras.ConditionalLoader {
                    id: timelineSidebar

                    when: sidebarTabGroup.currentTab == timelineSidebar
                    source: Qt.resolvedUrl("TimelineSidebar.qml")
                }
                PlasmaExtras.ConditionalLoader {
                    id: tagsSidebar

                    when: sidebarTabGroup.currentTab == tagsSidebar
                    source: Qt.resolvedUrl("TagsBar.qml")
                }
            }
        }
    }
}

