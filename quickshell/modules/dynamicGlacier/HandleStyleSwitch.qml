import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property string handleStyle: "bump"
    property string batteryText: ""
    property bool batteryCharging: false
    property int batteryLevel: 0
    property string statusText: ""
    property string fontFamily: "Noto Sans"
    property bool showBattery: false
    property bool compact: false

    signal handleStyleRequested(string style)

    Layout.fillWidth: true
    Layout.preferredHeight: root.compact ? 15 : 17
    spacing: root.compact ? 7 : 8

    Text {
        text: "bump"
        color: root.handleStyle === "bump" ? "#d9d9d9" : "#555555"
        font.family: root.fontFamily
        font.pixelSize: root.compact ? 10 : 11
        font.weight: root.handleStyle === "bump" ? Font.DemiBold : Font.Medium

        MouseArea {
            anchors.fill: parent
            anchors.margins: -5
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.handleStyleRequested("bump")
        }
    }

    Text {
        text: "/"
        color: "#303030"
        font.family: root.fontFamily
        font.pixelSize: root.compact ? 10 : 11
        font.weight: Font.DemiBold
    }

    Text {
        text: "strip"
        color: root.handleStyle === "strip" ? "#d9d9d9" : "#555555"
        font.family: root.fontFamily
        font.pixelSize: root.compact ? 10 : 11
        font.weight: root.handleStyle === "strip" ? Font.DemiBold : Font.Medium

        MouseArea {
            anchors.fill: parent
            anchors.margins: -5
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.handleStyleRequested("strip")
        }
    }

    Item {
        Layout.fillWidth: true

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.statusText
            color: "#9c9c9c"
            visible: root.statusText !== ""
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            font.family: root.fontFamily
            font.pixelSize: root.compact ? 10 : 11
            font.weight: Font.DemiBold
        }
    }

    Row {
        spacing: 3
        visible: root.showBattery && root.batteryLevel > 0

        MIcon {
            name: root.batteryCharging ? "bolt" : root.batteryLevel <= 20 ? "battery_alert" : "battery_full"
            size: root.compact ? 12 : 13
            color: root.batteryCharging ? "#4ade80" : root.batteryLevel <= 20 ? "#f87171" : "#ececec"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.batteryLevel + "%"
            color: "#ececec"
            font.family: root.fontFamily
            font.pixelSize: root.compact ? 10 : 11
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
