var ExtractTextPlugin = require("extract-text-webpack-plugin");
var path = require("path");

module.exports = {
  entry: "./app.js",
  output: {
    path: path.resolve(__dirname, "../priv/static"),
    filename: "bundle.js",
  },
  plugins: [
    new ExtractTextPlugin({
      filename: "styles.css",
    }),
  ],
  module: {
    loaders: [
      {
        test: /.js?$/,
        loader: "babel-loader",
        exclude: /node_modules/,
        query: {
          presets: [
            "es2015",
            "react",
            [
              "jsxz",
              {
                dir: "webflow",
              },
            ],
          ],
          plugins: [
            "./custom_plugin/my-babel-plugin.js",
            "babel-plugin-transform-object-rest-spread",
          ],
        },
      },
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({ use: "css-loader" }),
      },
    ],
  },
};
