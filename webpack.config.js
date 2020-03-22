'use strict'

const ChunkRenamePlugin = require("webpack-chunk-rename-plugin");
const { CleanWebpackPlugin } = require('clean-webpack-plugin'); // installed via npm
const CopyWebpackPlugin = require("copy-webpack-plugin");
const DojoWebpackPlugin = require("dojo-webpack-plugin");
//const MergeIntoSingleFilePlugin = require('webpack-merge-and-include-globally');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const StylelintPlugin = require('stylelint-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
//const WebpackMonitor = require('webpack-monitor');

const path = require("path");
const webpack = require("webpack");

module.exports = env => {
  const devMode = process.env.NODE_ENV !== 'production';
  return {
    context: path.join(__dirname, "UI"),
    entry: {
      'lsmb': 'lsmb/main',
      'login': 'lsmb/login',
      'lib': [
        'dojo/dom',
        'dojo/dom-style',
        'dojo/ready',
        'dojo/on',
        'dijit/Dialog',                 // main.html, login
        'dijit/Tooltip',                // elements.html, user.html, elements.html, new_user.html
        'dijit/form/ComboBox',          // setup, Is_LSMB_running
        'dijit/form/CurrencyTextBox',   // elements.html
        'dijit/form/MultiSelect',       // elements.html
        'dijit/form/NumberSpinner',     // balance_sheet, income_statement
        'dijit/form/Textarea',          // aa, ic, io, ir, is, oe, pe
        'dijit/layout/BorderContainer', // main.html
        'lsmb/accounts/AccountRestStore',
        'lsmb/accounts/AccountSelector',
        'lsmb/DateTextBox',
        'lsmb/FilteringSelect',
        'lsmb/Form',
        'lsmb/iframe',
        'lsmb/Invoice',
        'lsmb/InvoiceLine',
        'lsmb/InvoiceLines',
        'lsmb/journal/fx_checkbox',
        'lsmb/layout/TableContainer',
        'lsmb/MainContentPane',
        'lsmb/MaximizeMinimize',
        'lsmb/menus/Tree',
        'lsmb/parts/PartDescription',
        'lsmb/parts/PartRestStore',
        'lsmb/parts/PartSelector',
        'lsmb/payments/PostPrintButton',
        'lsmb/PrintButton',
        'lsmb/PublishCheckBox',
        'lsmb/PublishNumberTextBox',
        'lsmb/PublishRadioButton',
        'lsmb/PublishSelect',
        'lsmb/PublishToggleButton',
        'lsmb/Reconciliation',
        'lsmb/ReconciliationLine',
        'lsmb/reports/ComparisonSelector',
        'lsmb/reports/PeriodSelector',
        'lsmb/ResizingTextarea',
        'lsmb/SetupLoginButton',
        'lsmb/SimpleForm',
        'lsmb/SubscribeCheckBox',
        'lsmb/SubscribeNumberTextBox',
        'lsmb/SubscribeRadioButton',
        'lsmb/SubscribeSelect',
        'lsmb/SubscribeShowHide',
        'lsmb/SubscribeToggleButton',
        'lsmb/TemplateManager',
        'lsmb/users/ChangePassword'
      ]
    },

    output: {
      path: path.join(__dirname, "UI/js"),  // js path
      publicPath: 'js/',                    // images path
      pathinfo: devMode ? true : false,     // keep source references?
      filename: '[name].js',
      chunkFilename: '[name].[chunkhash].js'
    },

    module: {
      rules: [{
        test: /\.js$/,
        exclude: [/node_modules/, /dojo.js/],
        loader: 'eslint-loader',
        options: {
          configFile: '.eslintrc'
        },
        enforce: 'pre',
      },{
        test: /\.(png|jpe?g|gif)$/i,
        use: [{
          loader: 'url-loader',
          options: {
            limit: 100000
          }
        }]
      },{
        test: /\.svg$/,
        use: 'file-loader'
      },{
        test: /\.css$/,
        use: [
          { loader: MiniCssExtractPlugin.loader },
          { loader: 'style-loader' },
          {
            loader: 'css-loader',
            options: {
              importLoaders: 1,
              modules: true
            }
          }
        ],
      }
    ]},

    plugins: [
      new CleanWebpackPlugin({
        dry: false,
        verbose: false,
      }), // delete all files in the js directory without deleting this folder

      new webpack.HashedModuleIdsPlugin(), // so that file hashes don't change unexpectedly

      new StylelintPlugin({
        files: '**/*.css'
      }),

      // Copy non-packed resources needed by the app to the release directory
      new CopyWebpackPlugin([
        { context: "node_modules", from: "dijit/icons/**/*", to: "."},
        { context: "node_modules", from: "dijit/nls/**/*", to: "."},
        { context: "node_modules", from: "dijit/themes/**/*", to: "."},
        { context: "node_modules", from: "dojo/i18n/**/*", to: "."},
        { context: "node_modules", from: "dojo/nls/**/*", to: "."},
        { context: "node_modules", from: "dojo/resources/**/*", to: "."},
      ]),

      new DojoWebpackPlugin({
        loaderConfig: require("./UI/js-src/webpack/loaderConfig.js"),
        environment: {dojoRoot: "js"},    // used at run time for non-packed resources (e.g. blank.gif)
        buildEnvironment: {dojoRoot: "js-src"}, // used at build time
        locales: ["en"],
        async: true,
        noConsole: true
      }),

      // dojo/domReady (only works if the DOM is ready when invoked)
      new webpack.NormalModuleReplacementPlugin(
        /^dojo\/domReady!/, (data) => {
          const match = /^dojo\/domReady!(.*)$/.exec(data.request);
          data.request = "dojo/loaderProxy?loader=dojo/domReady!" + match[1];
      }),

      new webpack.NormalModuleReplacementPlugin(
        /^svg!/, function(data) {
          var match = /^svg!(.*)$/.exec(data.request);
          data.request = "dojo/loaderProxy?loader=svg&deps=dojo/text%21" + match[1] + "!" + match[1];
      }),

      new webpack.NormalModuleReplacementPlugin(/^css!/, function(data) {
        data.request = data.request.replace(/^css!/, "!style-loader!css-loader!less-loader!")
      }),

      // See https://stackoverflow.com/questions/51639588/load-internal-module-attribute-with-webpack
      /*new MergeIntoSingleFilePlugin({
          files: {
            "lsmb.css": [
                'UI/css/ledgersmb.css',
                'UI/css/login.css',
                'UI/css/setup.css',
                'UI/css/scripts/*.css',
                'UI/css/system/*.css'
            ],
          }
      }),*/

      new ChunkRenamePlugin({
        initialChunksWithEntry: true,
      }),

      new MiniCssExtractPlugin({
        filename: "[name].css",
        chunkFilename: "[id].css"
      }),

/*
      new WebpackMonitor({
        capture: true,
        launch: false,
      })
*/
    ],

    resolve: {
      extensions: ['.js']/*,
      alias: {
        lsmb: path.resolve(__dirname, 'UI/js-src/lsmb'),
        dojo: path.resolve(__dirname, 'UI/js-src/dojo'),
        dijit: path.resolve(__dirname, 'UI/js-src/dijit')
      }*/
    },

    resolveLoader: {
      modules: ["js-src", "node_modules"],
      alias: { "requirejs/text": "raw-loader" }
    },

    mode: devMode ? 'development' : 'production',

    optimization: {
      runtimeChunk: {
        name: 'runtime',
      },
      splitChunks: devMode ? {} : {
        chunks: 'all',
        maxInitialRequests: Infinity,
        minSize: 0,
        cacheGroups: {
          vendor: {   // That should be empty for Dojo?
            test: /[\\/]node_modules[\\/]/,
            name(module) {
              // get the name. E.g. node_modules/packageName/not/this/part.js
              // or node_modules/packageName
              const packageName = module.context.match(/[\\/]node_modules[\\/](.*?)([\\/]|$)/)[1];

              // npm package names are URL-safe, but some servers don't like @ symbols
              return `npm.${packageName.replace('@', '')}`;
            },
          },
        },
      },
      minimizer: devMode ? [] : [
        new TerserPlugin({
          parallel: true,
          sourceMap: devMode ? true : false,
          terserOptions: {
            ecma: 6,
          }
        }),
      ]
    },
    performance: { hints: /*devMode ? 'warning' :*/ false },

    devtool: "#source-map",
    devServer: {
			open: true,
			openPage: "login.html"
		}
  };
};
