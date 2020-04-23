/** @format */
/* eslint global-require:0, no-param-reassign:0, no-unused-vars:0 */

const ChunkRenamePlugin = require("webpack-chunk-rename-plugin");
const { CleanWebpackPlugin } = require("clean-webpack-plugin"); // installed via npm
const CopyWebpackPlugin = require("copy-webpack-plugin");
const DojoWebpackPlugin = require("dojo-webpack-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const Merge = require('webpack-merge');
const MergeIntoSingleFilePlugin = require("webpack-merge-and-include-globally");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const MultipleThemesCompile = require('webpack-multiple-themes-compile');
const StylelintPlugin = require("stylelint-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const WebpackMonitor = require("webpack-monitor");

const glob = require("glob");
const path = require("path");
const webpack = require("webpack");

const devMode = process.env.NODE_ENV !== "production";

// Inspired by https://github.com/webpack-contrib/style-loader/issues/269

// ////////////////////// PLUGINS ////////////////////////
// ///////////////////////////////////////////////////////

const CleanWebpackPluginOptions = {
   dry: false,
   verbose: false
}; // delete all files in the js directory without deleting this folder

const StylelintPluginOptions = {
   files: "**/*.css"
};

// Copy non-packed resources needed by the app to the release directory
const CopyWebpackPluginOptions = [
   { context: "node_modules", from: "dijit/icons/**/*", to: "." },
   { context: "node_modules", from: "dijit/nls/**/*", to: "." },
   { context: "node_modules", from: "dojo/i18n/**/*", to: "." },
   { context: "node_modules", from: "dojo/nls/**/*", to: "." },
   { context: "node_modules", from: "dojo/resources/**/*", to: "." }
   // { context: "node_modules", from: "dijit/themes/**/*", to: ".",
   //  test: /images\/(.+)\.(png|gif|svg)$/},
];

const MergeIntoSingleFilePluginOptions = {
   files: {
      "ledgersmb-common.css": [
         "UI/css/ledgersmb-common.css",
         "UI/css/login.css",
         "UI/css/setup.css",
         "UI/css/scripts/*.css",
         "UI/css/system/*.css"
      ]
   }
};

const DojoWebpackPluginOptions = {
   loaderConfig: require("./UI/js-src/webpack/loaderConfig.js"),
   environment: { dojoRoot: "js" }, // used at run time for non-packed resources (e.g. blank.gif)
   buildEnvironment: { dojoRoot: "js-src" }, // used at build time
   locales: ["en"],
   async: true,
   noConsole: true
};

/*
const IndexHtmlOptions = {
  template: PATHS.indexHTML,
  filename: 'index.html',
  excludeChunks: Object.keys(themesConfig)
  minify: {
    collapseWhitespace: true
  },
  hash: true,
  inject: 'head', // <=
  'files': {
    'css': [ '[name].bundle.css' ],
    'js': [ '[name].bundle.js'],
    'chunks': {
      'head': {
        'entry': '',
        'css': '[name].bundle.css'
      },
      'main': {
        'entry': '[name].bundle.js',
        'css': []
      },
    }
  }
};
*/
// dojo/domReady (only works if the DOM is ready when invoked)
const NormalModuleReplacementPluginOptionsDomReady = function (data) {
   const match = /^dojo\/domReady!(.*)$/.exec(data.request);
   data.request = "dojo/loaderProxy?loader=dojo/domReady!" + match[1];
};

const NormalModuleReplacementPluginOptionsSVG = function (data) {
   var match = /^svg!(.*)$/.exec(data.request);
   data.request =
      "dojo/loaderProxy?loader=svg&deps=dojo/text%21" +
      match[1] +
      "!" +
      match[1];
};

const NormalModuleReplacementPluginOptionsCSS = function (data) {
   data.request = data.request.replace(
      /^css!/,
      "!style-loader!css-loader!less-loader!"
   );
};

const ChunkRenamePluginOptions = {
   initialChunksWithEntry: true
};

const MiniCssExtractPluginOptions = {
   filename: "[name].css",
   chunkFilename: "[id].css"
};

const WebpackMonitorOptions = {
   capture: true,
   launch: falsee
};

const devServerOptions = {
  contentBase: 'js',
  compress: true,
  port: 6969,
  stats: 'errors-only',
  open: true,
  hot: true,
  openPage: ''
};

const pluginsDev = [
   new CleanWebpackPlugin(CleanWebpackPluginOptions),
   new webpack.HashedModuleIdsPlugin(webpack.HashedModuleIdsPluginOptions),
   new StylelintPlugin(StylelintPluginOptions),
   new CopyWebpackPlugin(CopyWebpackPluginOptions),
   new MergeIntoSingleFilePlugin(MergeIntoSingleFilePluginOptions),
   new DojoWebpackPlugin(DojoWebpackPluginOptions),

   new HtmlWebpackPlugin({
      template: "setup/begin_backup.html",
      filename: "setup/begin_backup.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/complete.html",
      filename: "setup/complete.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/complete_migration_revert.html",
      filename: "setup/complete_migration_revert.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/confirm_operation.html",
      filename: "setup/confirm_operation.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/credentials.html",
      filename: "setup/credentials.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/edit_user.html",
      filename: "setup/edit_user.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/list_databases.html",
      filename: "setup/list_databases.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/list_users.html",
      filename: "setup/list_users.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/migration_step.html",
      filename: "setup/migration_step.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/new_user.html",
      filename: "setup/new_user.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/select_coa.html",
      filename: "setup/select_coa.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/system_info.html",
      filename: "setup/system_info.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/template_info.html",
      filename: "setup/template_info.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/ui-db-credentials.html",
      filename: "setup/ui-db-credentials.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/upgrade/confirm.html",
      filename: "setup/upgrade_confirm.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/upgrade/describe.html",
      filename: "setup/upgrade_describe.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/upgrade/epilogue.html",
      filename: "setup/upgrade_epilogue.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/upgrade/grid.html",
      filename: "setup/upgrade_grid.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/upgrade/preamble.html",
      filename: "setup/upgrade_preamble.html"
   }),
   new HtmlWebpackPlugin({
      template: "setup/upgrade_info.html",
      filename: "setup/upgrade_info.html"
   }),

   new webpack.NormalModuleReplacementPlugin(
      /^dojo\/domReady!/,
      NormalModuleReplacementPluginOptionsDomReady
   ),
   new webpack.NormalModuleReplacementPlugin(
      /^svg!/,
      NormalModuleReplacementPluginOptionsSVG
   ),
   new webpack.NormalModuleReplacementPlugin(
      /^css!/,
      NormalModuleReplacementPluginOptionsCSS
   ),

   new ChunkRenamePlugin(ChunkRenamePluginOptions),
   new MiniCssExtractPlugin(MiniCssExtractPluginOptions),
   new WebpackMonitor(WebpackMonitorOptions)
];

const pluginsProd = pluginsDev; // TODO: refine...

var pluginsList = devMode ? pluginsDev : pluginsProd;

// ////////////////////// LOADERS ////////////////////////
// ///////////////////////////////////////////////////////
const javascript = {
   enforce: "pre",
   test: /\.js$/,
   exclude: [/node_modules/, /dojo.js/, /dojo/, /dijit/],
   loader: "eslint-loader",
   options: {
      configFile: ".eslintrc",
      failOnError: true
   }
};

const css = {
   test: /\.css$/,
   use: [
      { loader: MiniCssExtractPlugin.loader },
      { loader: "style-loader" },
      {
         loader: "css-loader",
         options: {
            importLoaders: 1,
            modules: true
         }
      },
      {
         loader: "resolve-url-loader", // improves resolution of relative paths
         options: {
            root: "./UI/"
         }
      }
   ]
};

const images = {
   test: /\.(png|jpe?g|gif)$/i,
   use: [
      {
         loader: "url-loader",
         options: {
            limit: 8192
         }
      }
   ]
};

const less = {
    test: /\.less$/,
    use: [
      { loader: 'style-loader' },
      { loader: 'css-loader', },
      { loader: 'less-loader',
        options: {
          lessOptions: {
            strictMath: true,
          },
        },
      },
    ],
};

const html = {
   test: /\.html$/,
   use: "html-loader"
};

const svg = {
   test: /\.svg$/,
   loader: "file-loader"
};

// /////////////////// OPTIMIZATIONS /////////////////////
// ///////////////////////////////////////////////////////
const optimizationList = {
   /*
      runtimeChunk: {
        name: 'runtime',
      },
      */
   splitChunks: devMode
      ? {}
      : {
           chunks: "all",
           maxInitialRequests: Infinity,
           minSize: 0,
           cacheGroups: {
              vendor: {
                 // That should be empty for Dojo?
                 test: /[\\/]node_modules[\\/]/,
                 name(module) {
                    // get the name. E.g. node_modules/packageName/not/this/part.js
                    // or node_modules/packageName
                    const packageName = module.context.match(
                       /[\\/]node_modules[\\/](.*?)([\\/]|$)/
                    )[1];

                    // npm package names are URL-safe, but some servers don't like @ symbols
                    return `npm.${packageName.replace("@", "")}`;
                 }
              }
           }
        },
   minimizer: devMode
      ? []
      : [
           new TerserPlugin({
              parallel: true,
              sourceMap: !!devMode,
              terserOptions: {
                 ecma: 6
              }
           })
        ]
};

// ///////////////////// FUNCTIONS ///////////////////////
// ///////////////////////////////////////////////////////
// Compute the list of files we want to keep
const excludedDirectories = glob.sync("./UI/**", {
   ignore: [
      "./UI/*.html",
      "./UI/lib/dynatable.html", // no ui-header.html
      "./UI/lib/elements.html",
      "./UI/lib/report_base.html",
      "./UI/lib/utilities.html",
      "./UI/Configure/**/*",
      "./UI/Configuration/**/*",
      "./UI/Contact/**/*",
      "./UI/Reports/**/*",
      "./UI/accounts/**/*",
      "./UI/asset/**/*",
      "./UI/budgetting/**/*",
      "./UI/business_units/**/*",
      "./UI/file/**/*",
      "./UI/import_csv/**/*",
      "./UI/inventory/**/*",
      "./UI/journal/**/*",
      "./UI/orders/**/*",
      "./UI/payments/**/*",
      "./UI/payroll/**/*",
      "./UI/reconciliation/**/*",
      "./UI/setup/**/*",
      "./UI/taxform/**/*",
      "./UI/templates/**/*",
      "./UI/timecards/**/*",
      "./UI/users/**/*"
   ]
});

// Remove the above list from the files below
const includedHtml = glob.sync("./UI/**/*.html", {
   ignore: excludedDirectories
});


// /////////////////// WEBPACK CONFIG /////////////////////
// ///////////////////////////////////////////////////////
const webpackConfigs = {
    context: path.join(__dirname, "UI"),

    // stats: 'verbose',

    entry: { lsmb: "lsmb/main" },

    output: {
        path: path.join(__dirname, "UI/js"), // js path
        publicPath: "js/", // images path
        pathinfo: !!devMode, // keep source references?
        filename: "[name].js",
        chunkFilename: "[name].[chunkhash].js"
    },

    module: {
        rules: [javascript, css, images, html, svg]
    },

    plugins: pluginsList,

    resolve: {
        extensions: [".js"]
    },

    resolveLoader: {
        modules: ["js-src", "node_modules"]
    },

    mode: devMode ? "development" : "production",

    optimization: optimizationList,

    performance: { hints: /* devMode ? 'warning' : */ false },

    devtool: "#source-map",

    devServer: devServerOptions
};

const multipleThemesCompileOptions = {
    cdw: path.join(__dirname, "UI"),
    outputName: "./dijit/themes/[name]/[name].css",
    themesConfig: {
      claro:  { dojo_theme: 'claro',  import: [ path.join(__dirname, "/js-src/dijit/themes/claro/claro.css" )]},
      nihilo: { dojo_theme: 'nihilo', import: [ path.join(__dirname, "/js-src/dijit/themes/nihilo/nihilo.css" )]},
      soria:  { dojo_theme: 'soria',  import: [ path.join(__dirname, "/js-src/dijit/themes/soria/soria.css" )]},
      tundra: { dojo_theme: 'tundra', import: [ path.join(__dirname, "/js-src/dijit/themes/tundra/tundra.css" )]}
    },
    lessContent: 'body{dojo_theme:@dojo_theme}'
};

module.exports = (env) => {
   return Merge(
    webpackConfigs,
    MultipleThemesCompile(multipleThemesCompileOptions)
  );
};
