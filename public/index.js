window.onload = function() {
  const wsScheme = location.protocol === "https:" ? "wss" : "ws";
  const wsUrl = `${wsScheme}://${window.location.host}/ws`;
  let wsInstance = createWs();
  document.wsInstance = wsInstance;
  let resetInterval = setInterval(() =>
  {
    if (wsInstance && wsInstance.readyState > 1) {
      wsInstance = createWs();
    }
  }, 5000);


  function createWs() {
    const supportedProtocol = "REFRESH";
    const ws = new WebSocket(wsUrl, supportedProtocol);
    let pingInt;

    ws.onopen = () => {
      if (ws.protocol !== supportedProtocol) {
        console.error(`Bad protocol. Client supports ${supportedProtocol} but got: ${ws.protocol}`);
        ws.close(3002);
        return;
      }

      console.log("WebSocket opened");
      pingInt = setInterval(function() {
        if (ws.readyState > 1) {
          clearInterval(pingInt);
        } else {
          console.debug("PING");
          ws.send("PING");
        }
      }, 2000);
    }

    ws.onclose = event => {
      console.warn(`WebSocket closed on ${wsUrl}`, event);
      setTimeout(() => window.location.reload(), 1000);
    }

    ws.onmessage = msg => {
      const data = msg.data;

      switch(data) {
        case "HELLO":
          console.log(data);
          break;
        case "REFRESH":
          console.log(data);
          ws.close(1000, data);
          location.reload();
          break;
        default:
          console.warn(`Unable to handle message: "${data}"`, msg);
      }
    };

    return ws;
  }
}
