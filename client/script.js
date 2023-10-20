//Websocekt variables
//const url = "ws://localhost:9876/myWebsocket"
const url = "ws://34.208.61.209:9000/CP_2"

const mywsServer = new WebSocket(url)

//DOM Elements
const myMessages = document.getElementById("messages")
const myInput = document.getElementById("message")
const sendBtn = document.getElementById("send")
const stopBtn = document.getElementById("stop")
sendBtn.disabled = true
sendBtn.addEventListener("click", sendMsg, false)
stopBtn.addEventListener("click", stopTransaction, false)

//Sending message from client
function sendMsg() {
    const text = myInput.value
    msgGeneration(text, "Client")
    //mywsServer.send(text)
    var msgId = 1;
    msgId = msgId + 1;
	var bootNot = [2,msgId.toString(),"BootNotification",{"chargePointSerialNumber":"CPG","chargePointVendor":"Matth","chargePointModel":"Ghost 1","chargeBoxSerialNumber":"CPG01","firmwareVersion":"1.0.0"}];
	mywsServer.send(JSON.stringify(bootNot));

    const interval = setInterval(function ping() {
        var msgId = 1;
        msgId = msgId + 1;
        var ocppHB = [2, msgId.toString(), "Heartbeat", {}];
        mywsServer.send(JSON.stringify(ocppHB));
    }, 60000);
}

//Sending message from client
function stopTransaction() {
    const text = 'Transaction Stoped';
    var currentDate = new Date();
    msgGeneration(text, "Client")
    //mywsServer.send(text)
    var msgId = 1;
    msgId = msgId + 1;
    var idTag = "App-apVkYs5n4/meo";//"00001234"; //
	//var bootNot = [2,msgId.toString(),"StopTransaction",{"chargePointSerialNumber":"CPG","chargePointVendor":"Matth","chargePointModel":"Ghost 1","chargeBoxSerialNumber":"CPG01","firmwareVersion":"1.0.0"}];
	//mywsServer.send(JSON.stringify(bootNot));
    var stpTra = [2, msgId.toString(), "StopTransaction", {"connectorId":"1", "meterStop":1200, "idTag":idTag, "timestamp":currentDate.toISOString(), "transactionId": 44}];
    mywsServer.send(JSON.stringify(stpTra), function ack(error) {
        var snVal = [2, msgId.toString(), "StatusNotification", {"connectorId":"1", "errorCode":"NoError", "status":"Finishing"}];
        mywsServer.send(JSON.stringify(snVal), function ack(error) { 
            var snVal = [2, msgId.toString(), "StatusNotification", {"connectorId":"1", "errorCode":"NoError", "status":"Available"}];
            mywsServer.send(JSON.stringify(snVal), function ack(error) { 
            
            });
        });
    });
  
}

//Creating DOM element to show received messages on browser page
function msgGeneration(msg, from) {
    const newMessage = document.createElement("h5")
    newMessage.innerText = `${from} says: ${msg}`
    myMessages.appendChild(newMessage)
}

//enabling send message when connection is open
mywsServer.onopen = function() {
    sendBtn.disabled = false
}

//handling message event
mywsServer.onmessage = function(event) {
    const { data } = event
    msgGeneration(data, "Server")
}