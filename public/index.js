console.log("TODO");

window.onload = function() {
  const wsProtocol = location.protocol === "https:" ? "wss" : "ws";
  const wsUrl = `${wsProtocol}://${window.location.host}/ws`;
  const ws = new WebSocket(wsUrl);

  ws.onopen = function() {
    console.log(`Socket opened on ${wsUrl}`);
    window.setInterval(function() {
      console.debug("...");
      ws.send("...");
    }, 2000);
  }

  ws.onclose = function() { console.warn(`Socket closed on ${wsUrl}`); }

  ws.onmessage = function(msg) {
    console.log(`Message on ${wsUrl}: ${msg.data}`);

    if (msg.data === 'REFRESH') {
      console.warn('Refreshing the page');
      ws.close(1000, "Refreshing the page");
      location.reload();
    }
  }
}
