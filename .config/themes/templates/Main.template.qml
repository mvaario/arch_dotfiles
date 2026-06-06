import QtQuick 2.15
import SddmComponents 2.0
import QtGraphicalEffects 1.15

Rectangle {
    property string selectedUser: ""

    function doLogin() {
        console.log("LOGIN:", selectedUser, sessionList.currentIndex)
        sddm.login(selectedUser, passwordField.text, sessionList.currentIndex)
    }

    Keys.onReturnPressed: doLogin()
    Keys.onEnterPressed: doLogin()
    width: 640
    height: 480
    Connections {
        target: sddm
        function onLoginSucceeded() {
                errorMessage.color = "steelblue"
                errorMessage.text = textConstants.loginSucceeded
        }

        function onLoginFailed() {
            passwordField.text = ""
            errorMessage.color = "red"
            errorMessage.text = textConstants.loginFailed
        }

        function onInformationMessage(message) {
            errorMessage.color = "red"
            errorMessage.text = message
        }

    }

    /* background image*/
    Background {
        id: bg
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: config.background
    }
    /* left side background */
    Rectangle {
        width: parent.width / 3
        height: parent.height

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        Item {
            anchors.fill: parent
            clip: true

            /* Blur left side */
            FastBlur {
                width: bg.width
                height: bg.height
                source: bg
                radius: 45
            }
        }
        /* add background color */
        Rectangle {
            anchors.fill: parent
            color: '#%alpha_hex%%background%'
            /* right side border */
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: "#%main%"
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 5
            width: parent.width / 2

            /* User list */
            ListView {
                id: userList
                width: parent.width
                height: 40
                model: userModel
                clip: true
                currentIndex: 0
                highlightMoveDuration: 0
                Component.onCompleted: {
                selectedUser = userList.contentItem.children[0].children[1].text
                    }
                
                delegate: Rectangle {
                    width: parent.width
                    height: 40
                    radius: 20
                    color: "#000000"
                    border.color: "#%main%"
                    border.width: 1

                    Text {
                        text: "󰀄"
                        font.pixelSize: 20
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#%main%"
                        font.bold: true
                    }

                    Text {
                        text: model.name
                        anchors.centerIn: parent
                        color: "#%main%"
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            userList.currentIndex = index
                            selectedUser = model.name
                        }
                    }
                }
            }
        
            /* empty space */
            Item {
                width: 1
                height: 5
            }


            /* Password box */
            Rectangle {
                width: parent.width
                height: 40
                radius: 20
                color: "#000000"
                border.color: "#%main%"
                border.width: 1

                TextInput {
                    id: passwordField
                    anchors.centerIn: parent
                    color: "#%main%"
                    font.bold: true
                    echoMode: TextInput.Password
                    focus: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            /* empty space */
            Item {
                width: 1
                height: 80
            }

            /* Login button */
            Rectangle {
                width: parent.width
                height: 40
                radius: 20
                color: "#%main%"

                Text {
                    anchors.centerIn: parent
                    font.bold: true
                    anchors.margins: 10
                    text: "Login"
                    color: "black"
                    
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        doLogin()
                    }
                }
            }

            /* Display manager list */
            ListView {
                id: sessionList
                width: parent.width
                height: 40
                model: sessionModel
                
                delegate: Rectangle {
                    radius: 10
                    color: "#000000"

                    Text {
                        height: 40
                        text: "Display 󰟀  :  " + model.name 
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        color: sessionList.currentIndex === index ? "#%main%" : "#000000"
                        font.bold: true

                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: sessionList.currentIndex = index
                    }
                }
            }

        }
    }
}