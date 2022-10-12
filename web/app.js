require("!!file-loader?name=[name].[ext]!./index.html");
/* required library for our React app */
var ReactDOM = require("react-dom");
var React = require("react");
var createReactClass = require("create-react-class");
const { Children } = require("react");

/* required css for our application */
require("./webflow//orders/css/orders.css");
require("./webflow/orders-detail/css/orders-detail.css");

var Page = createReactClass({
  render() {
    var orders = [
      {
        remoteid: "000000189",
        custom: {
          customer: { full_name: "TOTO & CIE" },
          billing_address: "Some where in the world",
        },
        items: 2,
      },
      {
        remoteid: "000000190",
        custom: {
          customer: { full_name: "Looney Toons" },
          billing_address: "The Warner Bros Company",
        },
        items: 3,
      },
      {
        remoteid: "000000191",
        custom: {
          customer: { full_name: "Asterix & Obelix" },
          billing_address: "Armorique",
        },
        items: 29,
      },
      {
        remoteid: "000000192",
        custom: {
          customer: { full_name: "Lucky Luke" },
          billing_address: "A Cowboy doesn't have an address. Sorry",
        },
        items: 0,
      },
    ];
    return (
      <JSXZ in="./orders/orders" sel=".container">
        <Z sel=".orders-body">
          {orders.map((order) => (
            <JSXZ in="./orders/orders" sel=".order">
              <Z sel=".order-num">{order.remoteid}</Z>
              <Z sel=".order-name">{order.custom.customer.full_name}</Z>
              <Z sel=".order-address">{order.custom.billing_address}</Z>
              <Z sel=".order-quantity">{order.items}</Z>
            </JSXZ>
          ))}
        </Z>
      </JSXZ>
    );
  },
});

ReactDOM.render(<Page />, document.getElementById("root"));
