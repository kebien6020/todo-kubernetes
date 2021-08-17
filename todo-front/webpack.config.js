const HtmlWebpackPlugin = require("html-webpack-plugin");
const {DefinePlugin} = require("webpack");

module.exports = {
  mode: 'development',
  devtool: 'source-map',
  output: {
    filename: '[contenthash].js',
    chunkFilename: '[contenthash].js',
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        use: 'babel-loader',
        exclude: /node_modules/,
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin(),
    new DefinePlugin({
      'process.env.API_URL': JSON.stringify(process.env.API_URL),
    })
  ],
}
