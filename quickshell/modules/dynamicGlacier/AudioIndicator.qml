import QtQuick

// Cava-style animated audio bars indicator.
// Shows when audio is actively playing. Dismissable on click.
Item {
    id: root

    property bool active: false
    property bool playing: false
    property bool dismissed: false
    property color barColor: "#e0e0e0"
    property color backgroundColor: "#000000"
    property color borderColor: "#1a1a1a"
    readonly property bool showing: active && !dismissed
    readonly property bool animating: showing && playing

    signal clicked

    width: chip.width
    height: chip.height
    opacity: showing ? 1 : 0
    visible: opacity > 0
    scale: showing ? 1 : 0.7

    Rectangle {
        id: chip

        width: 18
        height: 18
        radius: height / 2
        color: chipMouse.containsMouse ? "#0f0f0f" : root.backgroundColor
        border.width: 1
        border.color: root.borderColor

        Row {
            anchors.centerIn: parent
            spacing: 1

            Repeater {
                model: 3

                Rectangle {
                    id: bar

                    width: 2
                    height: root.animating ? (4 + index * 2) : 3
                    radius: 1
                    color: root.barColor
                    anchors.verticalCenter: parent.verticalCenter

                    SequentialAnimation on height {
                        running: root.animating
                        loops: Animation.Infinite

                        NumberAnimation {
                            to: 3 + (index % 3) * 2
                            duration: 240 + index * 60
                            easing.type: Easing.InOutSine
                        }

                        NumberAnimation {
                            to: 8 - (index % 2) * 3
                            duration: 280 + index * 50
                            easing.type: Easing.InOutSine
                        }
                    }
                }
            }
        }

        MouseArea {
            id: chipMouse

            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.dismissed = true;
                root.clicked();
            }
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Behavior on scale {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
}
