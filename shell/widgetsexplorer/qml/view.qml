
import Qt 4.7
import Plasma 0.1 as Plasma

Rectangle {
    color: Qt.rgba(0,0,0,0.4)

    GridView {
        id: gridView

        anchors.fill: parent
        anchors.topMargin: 32
        anchors.bottomMargin: 32
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        model: myModel
        flow: GridView.LeftToRight
        snapMode: GridView.SnapToRow
        cellWidth: width/6
        cellHeight: height/4
        clip: true
        signal clicked

        delegate: Component {
            Item {
                id: wrapper
                width: wrapper.GridView.view.cellWidth-40
                height: wrapper.GridView.view.cellWidth-40

                Plasma.IconWidget {
                    minimumIconSize : "64x64"
                    maximumIconSize : "64x64"
                    preferredIconSize : "64x64"
                    minimumSize.width: wrapper.width
                    minimumSize.height: wrapper.height
                    id: resultwidget
                    icon: decoration
                    text: display
                }

                MouseArea {
                    id: mousearea
                    
                    anchors.fill: parent
                    onClicked : {
                        gridView.currentIndex = index
                        gridView.clicked()
                    }
                }
            }
        }
    }
}
