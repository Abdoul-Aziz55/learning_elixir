require("!!file-loader?name=[name].[ext]!./index.html");
/* required library for our React app */
var ReactDOM = require("react-dom");
var React = require("react");
var createReactClass = require("create-react-class");

/* required css for our application */
require("./webflow/Layout/Header/Orders/css/orders.css");
require("./webflow/Layout/Header/Order/css/order.css");
require("./webflow/Layout/css/layout.css");
require("./webflow/Layout/Header/css/header.css");
require("./webflow/modals/css/confirmation.css");
require("./webflow/loader/css/loader.css");

var XMLHttpRequest = require("xhr2");
var HTTP = new (function () {
  this.get = (url) => this.req("GET", url);
  this.delete = (url) => this.req("DELETE", url);
  this.post = (url, data) => this.req("POST", url, data);
  this.put = (url, data) => this.req("PUT", url, data);

  this.req = (method, url, data) =>
    new Promise((resolve, reject) => {
      var req = new XMLHttpRequest();
      req.open(method, url);
      req.responseType = "text";
      req.setRequestHeader("accept", "application/json,*/*;0.8");
      req.setRequestHeader("content-type", "application/json");
      req.onload = () => {
        if (req.status >= 200 && req.status < 300) {
          resolve(req.responseText && JSON.parse(req.responseText));
        } else {
          reject({ http_code: req.status });
        }
      };
      req.onerror = (err) => {
        reject({ http_code: req.status });
      };
      req.send(data && JSON.stringify(data));
    });
})();

//remote props object
var remoteProps = {
  // user: (props)=>{
  //   return {
  //     url: "/api/me",
  //     prop: "user"
  //   }
  // },
  orders: (props) => {
    // if(!props.user)
    //   return
    // var qs = { ...props.qs }; //, user_id: props.user.value.id}
    // var query = Qs.stringify(qs);
    return {
      url: "http://localhost:4001/orders", // + (query == "" ? "" : "?" + query),
      prop: "orders",
    };
  },
  order: (props) => {
    return {
      url: "http://localhost:4001/order/" + props.order_id,
      prop: "order",
    };
  },
};

function addRemoteProps(props) {
  var When = require("when");
  return new Promise((resolve, reject) => {
    //As our function call for nework data, we need to create a Promise that will resolve when all the
    //API call will resolve
    //Here we could call `[].concat.apply` instead of `Array.prototype.concat.apply`
    //apply first parameter define the `this` of the concat function called
    //Ex [0,1,2].concat([3,4],[5,6])-> [0,1,2,3,4,5,6]
    // <=> Array.prototype.concat.apply([0,1,2],[[3,4],[5,6]])
    //Also `var list = [1,2,3]` <=> `var list = new Array(1,2,3)`
    var remoteProps = Array.prototype.concat.apply(
      [],
      props.handlerPath
        .map((c) => c.remoteProps) // -> [[remoteProps.user], [remoteProps.orders], null]
        .filter((p) => p) // -> [[remoteProps.user], [remoteProps.orders]]
    );
    var remoteProps = remoteProps
      .map((spec_fun) => spec_fun(props)) // -> 1st call [{url: '/api/me', prop: 'user'}, undefined]
      // -> 2nd call [{url: '/api/me', prop: 'user'}, {url: '/api/orders?user_id=123', prop: 'orders'}]
      .filter((specs) => specs) // get rid of undefined from remoteProps that don't match their dependencies
      .filter(
        (specs) => !props[specs.prop] || props[specs.prop].url != specs.url
      ); // get rid of remoteProps already resolved with the url
    if (remoteProps.length == 0) return resolve(props);

    var promise = When.map(
      // Returns a Promise that either on a list of resolved remoteProps, or on the rejected value by the first fetch who failed
      remoteProps.map((spec) => {
        // Returns a list of Promises that resolve on list of resolved remoteProps ([{url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}])
        return HTTP.get(spec.url).then((result) => {
          spec.value = result;
          return spec;
        }); // we want to keep the url in the value resolved by the promise here. spec = {url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}
      })
    );

    When.reduce(
      promise,
      (acc, spec) => {
        // {url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}
        acc[spec.prop] = { url: spec.url, value: spec.value };
        return acc;
      },
      props
    ).then((newProps) => {
      addRemoteProps(newProps).then(resolve, reject);
    }, reject);
  });
}

var cn = function () {
  var args = arguments,
    classes = {};
  for (var i in args) {
    var arg = args[i];
    if (!arg) continue;
    if ("string" === typeof arg || "number" === typeof arg) {
      arg
        .split(" ")
        .filter((c) => c != "")
        .map((c) => {
          classes[c] = true;
        });
    } else if ("object" === typeof arg) {
      for (var key in arg) classes[key] = arg[key];
    }
  }
  return Object.keys(classes)
    .map((k) => (classes[k] && k) || "")
    .join(" ");
};

var DeleteModal = createReactClass({
  render() {
    return (
      <JSXZ in="./modals/confirmation" sel=".modal-wrapper">
        <Z sel=".confirmation-question">{this.props.message}</Z>
        <Z sel=".cancel" onClick={() => this.props.callback(false)}>
          <ChildrenZ />
        </Z>
        <Z sel=".confirm" onClick={() => this.props.callback(true)}>
          <ChildrenZ />
        </Z>
      </JSXZ>
    );
  },
});

var setLoaderState = function (newState) {
  this.setState((prevState) => ({ ...prevState, loader: newState }));
};

var Loader = createReactClass({
  render() {
    return (
      <JSXZ in="./loader/loader" sel=".loader-wrapper">
        <Z sel=".loading">
          <ChildrenZ />
        </Z>
        <Z sel=".message">{this.props.message}</Z>
      </JSXZ>
    );
  },
});

var Layout = createReactClass({
  getInitialState: function () {
    setLoaderState = setLoaderState.bind(this);
    return { modal: null, loader: { show: false, message: null } };
  },
  modal(modal_data) {
    this.setState((prevState) => ({
      ...prevState,
      modal: {
        ...modal_data,
        callback: (res) => {
          this.setState({ modal: null }, () => {
            if (modal_data.callback) modal_data.callback(res);
          });
        },
      },
    }));
  },
  loader({ promise, show, message, route }) {
    setLoaderState({ show: show, message: message });
    return new Promise((resolve, reject) => {
      promise.then(
        (result) => {
          browserState.delete(route);
          setLoaderState({ show: show, message: "Updating orders..." });
          addRemoteProps(browserState).then(
            (res) => {
              browserState = res;
              onPathChange();
              resolve(result);
            },
            (err) => reject(err)
          );
        },
        (err) => reject(err)
      );
    });
  },
  render() {
    var modal_component = {
      delete: (props) => <DeleteModal {...props} />,
    }[this.state.modal && this.state.modal.type];
    modal_component = modal_component && modal_component(this.state.modal);

    var props = {
      ...this.props,
      modal: this.modal,
      loader: this.loader,
    };
    console.log(this.state.loader);
    return (
      <JSXZ in="./Layout/layout" sel=".layout">
        <Z sel=".layout-container">
          <this.props.Child {...props} />
        </Z>
        <Z
          sel=".modal-wrapper"
          className={cn(classNameZ, { hidden: !modal_component })}
        >
          {modal_component}
        </Z>

        <Z
          sel=".loader-wrapper"
          className={cn(classNameZ, { hidden: !this.state.loader.show })}
        >
          <Loader message={this.state.loader.message} />
        </Z>
      </JSXZ>
    );
  },
});

var Header = createReactClass({
  render() {
    return (
      <JSXZ in="./Layout/Header/header" sel=".header">
        <Z sel=".header-container">
          <this.props.Child {...this.props} />
        </Z>
      </JSXZ>
    );
  },
});

var Orders = createReactClass({
  statics: {
    remoteProps: [remoteProps.orders],
  },
  componentDidMount() {
    GoTo(this.props.route, "", "");
  },
  delete_modal: function (id_to_delete) {
    this.props.modal({
      type: "delete",
      title: "Order deletion",
      message: `Are you sure you want to delete this ?`,
      callback: (value) => {
        if (value === true) {
          var promise = new Promise((resolve, reject) => {
            HTTP.get("http://localhost:4001/delete?id=" + id_to_delete).then(
              (res) => resolve(res),
              (err) => reject(err)
            );
          });
          this.props
            .loader({
              promise: promise,
              show: true,
              message: "Deleting order...",
              route: this.props.route,
            })
            .then(
              (res) => {
                setLoaderState({ show: false, message: null });
              },
              (err) => alert(err)
            );
        }
      },
    });
  },
  render() {
    return (
      <JSXZ in="./Layout/Header/Orders/orders" sel=".container">
        <Z sel=".orders-body">
          {this.props.orders.value.map((order) => (
            <JSXZ in="./Layout/Header/Orders/orders" sel=".order">
              <Z sel=".order-num">{order.remoteid}</Z>
              <Z sel=".order-name">{order.custom.customer.full_name}</Z>
              <Z sel=".order-address">
                {order.custom.billing_address.street},{" "}
                {order.custom.billing_address.postcode}{" "}
                {order.custom.billing_address.city}
              </Z>
              <Z sel=".order-quantity">{order.custom.items.length}</Z>
              <Z
                sel=".order-details-butt"
                onClick={() => GoTo("order", order.id, "")}
              >
                <ChildrenZ />
              </Z>
              <Z
                sel=".order-delete-butt"
                onClick={() => this.delete_modal(order.id)}
              >
                <ChildrenZ />
              </Z>
            </JSXZ>
          ))}
        </Z>
      </JSXZ>
    );
  },
});

var Order = createReactClass({
  statics: {
    remoteProps: [remoteProps.order],
  },
  render() {
    var tot_price = 0;
    return (
      <JSXZ in="./Layout/Header/Order/order" sel=".container">
        <Z sel=".return-butt" onClick={() => GoTo("orders", "", "")}>
          <ChildrenZ />
        </Z>
        <Z sel=".command-info-body">
          <JSXZ in="./Layout/Header/Order/order" sel=".command-info-item">
            <Z sel=".command-info-num">{this.props.order.value.remoteid}</Z>
            <Z sel=".command-info-name">
              {this.props.order.value.custom.customer.full_name}
            </Z>
            <Z sel=".command-info-address">
              {this.props.order.value.custom.billing_address.street},{" "}
              {this.props.order.value.custom.billing_address.postcode}{" "}
              {this.props.order.value.custom.billing_address.city}
            </Z>
          </JSXZ>
        </Z>
        <Z sel=".command-details-body">
          {this.props.order.value.custom.items.map((item) => {
            var item_tot_price = (
              item.unit_price * item.quantity_to_fetch
            ).toFixed(2);
            tot_price = (Number(tot_price) + Number(item_tot_price)).toFixed(2);

            return (
              <JSXZ
                in="./Layout/Header/Order/order"
                sel=".command-details-item"
              >
                <Z sel=".item-name">{item.product_title}</Z>
                <Z sel=".item-unit-price">{item.unit_price} €</Z>
                <Z sel=".item-quantity">{item.quantity_to_fetch}</Z>
                <Z sel=".item-tot-price">{item_tot_price} €</Z>
              </JSXZ>
            );
          })}
        </Z>
        <Z sel=".order-tot-price">{tot_price} €</Z>
      </JSXZ>
    );
  },
});

var Child = createReactClass({
  render() {
    var [ChildHandler, ...rest] = this.props.handlerPath;
    return <ChildHandler {...this.props} handlerPath={rest} />;
  },
});

var ErrorPage = createReactClass({
  render() {
    return (
      <div>
        Error. Message: {this.props.message} code:{this.props.code}
      </div>
    );
  },
});

// routes allowed
var routes = {
  orders: {
    path: (params) => {
      return "/";
    },
    match: (path, qs) => {
      return path == "/" && { handlerPath: [Layout, Header, Orders] };
    },
  },
  order: {
    path: (params) => {
      return "/order/" + params;
    },
    match: (path, qs) => {
      var r = new RegExp("/order/([^/]*)$").exec(path);
      return r && { handlerPath: [Layout, Header, Order], order_id: r[1] };
    },
  },
};

//global variable to describe state of the browser
var browserState = {
  Child: Child,
  delete: (key) => {
    if (browserState.hasOwnProperty(key)) {
      delete browserState[key];
    }
  },
};

//query string and cookie
var Qs = require("qs");
var Cookie = require("cookie");

// function to navigate
var GoTo = (route, params, query) => {
  var qs = Qs.stringify(query);
  var url = routes[route].path(params) + (qs == "" ? "" : "?" + qs);
  history.pushState({}, "", url);
  onPathChange();
};

function onPathChange() {
  var path = location.pathname;
  var qs = Qs.parse(location.search.slice(1));
  var cookies = Cookie.parse(document.cookie);
  browserState = {
    ...browserState,
    path: path,
    qs: qs,
    cookie: cookies,
  };

  var route, routeProps;
  //We try to match the requested path to one our our routes
  for (var key in routes) {
    routeProps = routes[key].match(path, qs);
    if (routeProps) {
      route = key;
      break;
    }
  }
  browserState = {
    ...browserState,
    ...routeProps,
    route: route,
  };
  //If we don't have a match, we render an Error component
  if (!route)
    return ReactDOM.render(
      <ErrorPage message={"Not Found"} code={404} />,
      document.getElementById("root")
    );
  addRemoteProps(browserState).then(
    (props) => {
      browserState = props;
      //Log our new browserState
      console.log(browserState);
      //Render our components using our remote data
      ReactDOM.render(
        <Child {...browserState} />,
        document.getElementById("root")
      );
    },
    (res) => {
      ReactDOM.render(
        <ErrorPage message={"Shit happened"} code={res.http_code} />,
        document.getElementById("root")
      );
    }
  );
}

window.addEventListener("popstate", () => {
  onPathChange();
});
onPathChange();
