/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtLocation       5.3
import QtPositioning    5.3

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FlightMap     1.0

/// Rally Point map visuals
Item {
    z: QGroundControl.zOrderMapItems

    property var    map
    property var    myRallyPointController
    property bool   interactive:            false   ///< true: user can interact with items
    property bool   planView:               false   ///< true: visuals showing in plan view

    property bool   _interactive:           interactive
    property var    _rallyPointsComponent
    property bool   _rallyPointsSupported:  myRallyPointController.rallyPointsSupported
    property var    _rallyPoints:           myRallyPointController.points

    Component.onCompleted: {
        _rallyPointsComponent = rallyPointsComponent.createObject(map)
    }

    Component.onDestruction: {
        _rallyPointsComponent.destroy()
    }

    Component {
        id: rallyPointComponent

        MapQuickItem {
            id:             itemIndicator
            anchorPoint.x:  sourceItem.anchorPointX
            anchorPoint.y:  sourceItem.anchorPointY
            z:              QGroundControl.zOrderMapItems

            property var rallyPointObject

            sourceItem: MissionItemIndexLabel {
                id:         itemIndexLabel
                label:      qsTr("R", "rally point map item label")
                checked:    _editingLayer == _layerRallyPoints ? rallyPointObject == myRallyPointController.currentRallyPoint : false

                onClicked: myRallyPointController.currentRallyPoint = rallyPointObject
            }
        }
    }

    // Add all rally points to the map
    Component {
        id: rallyPointsComponent

        Repeater {
            model: _rallyPoints

            delegate: Item {
                property var _visuals: [ ]

                Component.onCompleted: {
                    var rallyPoint = rallyPointComponent.createObject(map)
                    rallyPoint.coordinate = Qt.binding(function() { return object.coordinate })
                    rallyPoint.rallyPointObject = Qt.binding(function() { return object })
                    map.addMapItem(rallyPoint)
                    _visuals.push(rallyPoint)
/*
                    var dragArea = dragAreaComponent.createObject(map, { "itemIndicator": dragHandle, "itemCoordinate": object.coordinate })
                    dragArea.polygonVertex = Qt.binding(function() { return index })
                    _visuals.push(dragHandle)
                    _visuals.push(dragArea)
*/
                }

                Component.onDestruction: {
                    for (var i=0; i<_visuals.length; i++) {
                        _visuals[i].destroy()
                    }
                    _visuals = [ ]
                }
            }
        }
    }

}