/** @format */
/* eslint global-require:0, no-param-reassign:0, no-unused-vars:0 */

const getLogger = require('webpack-log');
const log = getLogger({ name: 'webpack-ledgersmb' });

const ChunkRenamePlugin = require("webpack-chunk-rename-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const DojoWebpackPlugin = require("dojo-webpack-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const Merge = require('webpack-merge');
const MergeIntoSingleFilePlugin = require("webpack-merge-and-include-globally");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const MultipleThemesCompile = require('webpack-multiple-themes-compile');
const StylelintPlugin = require("stylelint-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const UnusedWebpackPlugin = require('unused-webpack-plugin');
const WebpackMonitor = require("webpack-monitor");

const { CleanWebpackPlugin } = require("clean-webpack-plugin"); // installed via npm

const _ = require('lodash');  // To use merge and reduce, for we are not using ES6
const glob = require("glob");
const path = require("path");
const webpack = require('webpack');

const devMode = process.env.NODE_ENV !== "production";

/////////////////////// FUNCTIONS ///////////////////////
/////////////////////////////////////////////////////////
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

//////////////////////// LOADERS ////////////////////////
/////////////////////////////////////////////////////////
const javascript = {
   enforce: "pre",
   test: /\.js$/,
   exclude: [/node_modules/, /dojo.js/, /dojo/, /dijit/],
   use: [{
      loader: 'babel-loader',
      options: {
         presets: ['@babel/preset-env']
      }
    },{
      loader: "eslint-loader",
      options: {
         configFile: ".eslintrc",
         failOnError: true
      }
   }]
};

// Used in css loader definition below and webpack-multiple-themes-compile plugin
const cssRules = [
   // Creates `style` nodes from JS strings
   //'style-loader', // requires a document, thus js code. Not for css only
   // Translates CSS into CommonJS
   {
      loader: 'css-loader',
      options: {
         modules: true,
         sourceMap: !devMode,
         importLoaders: 1
      },
   },
   // inline images
   {
      loader: 'postcss-loader',
      options: {
         ident: 'postcss',
         plugins: [
           require('postcss-import')(),
           require('postcss-url')(),
           //require('postcss-preset-env')(),
           // add your "plugins" here
           // ...
           // and if you want to compress,
           // just use css-loader option that already use cssnano under the hood
           require("postcss-browser-reporter")(),
           require("postcss-reporter")()
         ]
       }
   },
   // Compiles Sass to CSS
   {
      loader: 'sass-loader',
      options: {
         sourceMap: !devMode
       }
   },
];

const css = {
   test: /\.s[ac]ss$/i,
   use: cssRules
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

const lessRules = [
   { loader: 'style-loader' },
   { loader: 'css-loader' },
   { loader: 'less-loader' }
];

const less = {
    test: /\.less$/,
    use: lessRules,
};


const html = {
   test: /\.html$/,
   use: "html-loader"
};

const svg = {
   test: /\.svg$/,
   loader: "file-loader"
};

//////////////////////// PLUGINS ////////////////////////
/////////////////////////////////////////////////////////

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

const multipleThemesCompileOptions = {
   cwd: path.join(__dirname, "UI"),
   cacheDir: "js",
   styleLoaders: cssRules,
   preHeader: '/* stylelint-disable */',
   outputName: "/js/dijit/themes/[name]/[name].css",
   themesConfig: {
     claro:  { dojo_theme: 'claro',  import: [ "../js-src/dijit/themes/claro/claro.css" ]},
     nihilo: { dojo_theme: 'nihilo', import: [ "../js-src/dijit/themes/nihilo/nihilo.css" ]},
     soria:  { dojo_theme: 'soria',  import: [ "../js-src/dijit/themes/soria/soria.css" ]},
     tundra: { dojo_theme: 'tundra', import: [ "../js-src/dijit/themes/tundra/tundra.css" ]}
   },
   lessContent: '', // 'body{dojo_theme:@dojo_theme}'
};

const IndexHtmlOptions = {
  excludeChunks: Object.keys(multipleThemesCompileOptions.themesConfig), // Exclude Dijit themes
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

const UnusedWebpackPluginOptions = {
   // Source directories
   directories: ['js-src/lsmb'],
   // Exclude patterns
   exclude: ['*.test.js'],
   // Root directory (optional)
   root: path.join(__dirname, 'UI')
 };

 const WebpackMonitorOptions = {
   capture: true,
   launch: false
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

const htmls = includedHtml.map(
     function(val) {
       const filenameRegex = /(\/UI\/)?([\w\d_\-\/]*)\.?[^\\\/]*$/i;
       const template = val.match(filenameRegex)[2];
       const filename = val.replace('./UI/','');
       return new HtmlWebpackPlugin(_.merge(
            {
               template: filename,
               filename: filename
            },
            IndexHtmlOptions
       ));
     });

var pluginsDev = [
   new CleanWebpackPlugin(CleanWebpackPluginOptions),
   new webpack.HashedModuleIdsPlugin(webpack.HashedModuleIdsPluginOptions),
   new StylelintPlugin(StylelintPluginOptions),
   new CopyWebpackPlugin(CopyWebpackPluginOptions),
   new MergeIntoSingleFilePlugin(MergeIntoSingleFilePluginOptions),
   new DojoWebpackPlugin(DojoWebpackPluginOptions)];

pluginsDev = pluginsDev.concat(htmls,
   [
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
   new UnusedWebpackPlugin(UnusedWebpackPluginOptions),
   new WebpackMonitor(WebpackMonitorOptions)
   ]
);

const pluginsProd = pluginsDev; // TODO: refine...

var pluginsList = devMode ? pluginsDev : pluginsProd;

///////////////////// OPTIMIZATIONS /////////////////////
/////////////////////////////////////////////////////////
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

///////////////////// WEBPACK CONFIG /////////////////////
/////////////////////////////////////////////////////////
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
        rules: [javascript, html, css, images, svg]
    },

    plugins: pluginsList,

    resolve: {
        extensions: [".js", ".scss"]
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

module.exports = (env) => {
   return Merge(
    //webpackConfigs,
    {mode: devMode ? "development" : "production"},
    MultipleThemesCompile(multipleThemesCompileOptions)
  );
};
