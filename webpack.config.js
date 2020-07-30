/** @format */
/* eslint global-require:0, no-param-reassign:0, no-unused-vars:0, no-console: 0, class-methods-use-this:0 */
/* global getConfig */

const fs = require("fs");
const glob = require("glob");
const path = require("path");
const webpack = require("webpack");

const CopyWebpackPlugin = require("copy-webpack-plugin");
const DojoWebpackPlugin = require("dojo-webpack-plugin");
const { DuplicatesPlugin } = require("inspectpack/plugin");
const ExtractCssChunks = require("extract-css-chunks-webpack-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const ManifestPlugin = require("webpack-manifest-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const StatsPlugin = require("stats-webpack-plugin");
const StylelintPlugin = require("stylelint-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const UnusedWebpackPlugin = require("unused-webpack-plugin");
const VirtualModulePlugin = require("virtual-module-webpack-plugin");

const { CleanWebpackPlugin } = require("clean-webpack-plugin"); // installed via npm

// Segment the application in features. Files in those directories have most
// chances to be used together or at the same period.
// If only we could make them lazyloading instead of pulling all in ui-header
const lsmbFeatures = [
    "accounts",
    "asset",
    "budgetting",
    "business_units",
    "Configuration",
    "Contact",
    "file",
    "import_csv",
    "inventory",
    "journal",
    "lib",
    "orders",
    "payments",
    "payroll",
    "reconciliation",
    "Reports",
    "setup",
    "taxform",
    "templates",
    "timecards",
    "users"
];

const argv = require("yargs").argv;
const prodMode =
    process.env.NODE_ENV === "production" ||
    argv.p ||
    argv.mode === "production";

// Make sure all modules follow desired mode
process.env.NODE_ENV = prodMode ? "production" : "development";

/* FUNCTIONS */

// Generate entries from file pattern
const mapFilenamesToEntries = (cwd, pattern) =>
    glob.sync(pattern, { cwd: cwd }).reduce((entries, filename) => {
        const [, name] = filename.match(/([^/]+)\.css$/);
        return { ...entries, [name]: filename };
    }, {});

const _dijitThemes = "+(claro|nihilo|soria|tundra)";
const lsmbCSS = {
    ...mapFilenamesToEntries("UI", "css/!(ledgersmb-common).css"),
    ...mapFilenamesToEntries(
        "..",
        "node_modules/dijit/themes/" +
            _dijitThemes +
            "/" +
            _dijitThemes +
            ".css"
    )
};

var includedRequires = [
    "dojo/has!webpack?dojo-webpack-plugin/amd/dojoES6Promise"
];

function findDataDojoTypes(fileName) {
    var content = "" + fs.readFileSync(fileName);
    // Return unique data-dojo-type refereces
    return (
        content.match(/(?<=['"]?data-dojo-type['"]?\s*=\s*")([^"]+)(?=")/gi) ||
        []
    ).filter((x, i, a) => a.indexOf(x) === i);
}

// Compute used data-dojo-type
const includedHtml = glob.sync("**/*.html", {
    ignore: ["lib/ui-header.html", "js/**", "setup/upgrade/*"],
    cwd: "UI"
});

const htmls = includedHtml.map(function (filename) {
    const requires = findDataDojoTypes("UI/" + filename);
    includedRequires.push(...requires);
    return new HtmlWebpackPlugin({
        inject: false, // Tags are injected manually in the content below
        minify: prodMode // Adjust t/16-schema-upgrade-html.t if prodMode is used,
            ? {
                  collapseWhitespace: true,
                  ignoreCustomFragments: [/\[%[\s\S]*?%\]/],
                  removeComments: true,
                  removeRedundantAttributes: true,
                  removeScriptTypeAttributes: true,
                  removeStyleLinkTypeAttributes: true,
                  useShortDoctype: true
              }
            : false,
        excludeChunks: [...Object.keys(lsmbCSS)],
        template: filename,
        filename: filename.replace(/(js-src\/)?/, ""),
        chunks: requires
    });
});

// Pull UI/js-src/lsmb
includedRequires = includedRequires
    .concat(
        glob
            .sync(
                "lsmb/**/!(main|bootstrap|lsmb.profile|webpack.loaderConfig).js",
                {
                    cwd: "UI/js-src/"
                }
            )
            .map(function (file) {
                return file.replace(/\.js$/, "");
            })
    )
    .filter((x, i, a) => a.indexOf(x) === i)
    .sort();

/* LOADERS */

const javascript = {
    enforce: "pre",
    test: /\.js$/,
    use: [
        {
            loader: "babel-loader",
            options: {
                presets: ["@babel/preset-env"]
            }
        },
        {
            loader: "eslint-loader",
            options: {
                configFile: ".eslintrc",
                failOnError: true
            }
        }
    ],
    exclude: /node_modules/
};

const css = {
    test: /\.css$/i,
    use: [
        {
            loader: ExtractCssChunks.loader,
            options: {
                hmr: !prodMode
            }
        },
        "css-loader"
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

const html = {
    test: /.+(?<!ui-header)\.html$/,
    loader: "raw-loader"
};

const ejs = {
    test: /ui-header\.html$/,
    use: [
        {
            loader: "ejs-loader",
            options: {
                esModule: false
            }
        }
    ]
};

const svg = {
    test: /\.svg$/,
    loader: "file-loader"
};

/* PLUGINS */

const CleanWebpackPluginOptions = {
    dry: false,
    verbose: false
}; // delete all files in the js directory without deleting this folder

const StylelintPluginOptions = {
    files: "**/*.css"
};

// Copy non-packed resources needed by the app to the release directory
const CopyWebpackPluginOptions = {
    patterns: [
        //        { context: "../node_modules", from: "dijit/icons/**/*", to: "." },
        //        { context: "../node_modules", from: "dijit/nls/**/*", to: "." },
        //        { context: "../node_modules", from: "dojo/nls/**/*", to: "." },
        { context: "../node_modules", from: "dojo/resources/**/*", to: "." },
        { context: ".", from: "setup/upgrade/*", to: "." } // html fragments
    ],
    options: {
        concurrency: 100
    }
};

const DojoWebpackPluginOptions = {
    loaderConfig: require("./UI/js-src/lsmb/webpack.loaderConfig.js"),
    environment: { dojoRoot: "UI/js" }, // used at run time for non-packed resources (e.g. blank.gif)
    buildEnvironment: { dojoRoot: "node_modules" }, // used at build time
    locales: [
        "ar",
        "bg",
        "ca",
        "cs",
        "da",
        "de",
        "el",
        "en",
        "es",
        "fi",
        "fr",
        "hu",
        "id",
        "it",
        "nb",
        "nl",
        "pl",
        "pt",
        "ru",
        "sv",
        "tr",
        "uk",
        "zh",
        "zh-tw"
    ],
    noConsole: true
};

// dojo/domReady (only works if the DOM is ready when invoked)
const NormalModuleReplacementPluginOptionsDomReady = function (data) {
    const match = /^dojo\/domReady!(.*)$/.exec(data.request);
    /* eslint-disable-next-line no-param-reassign */
    data.request = "dojo/loaderProxy?loader=dojo/domReady!" + match[1];
};

const NormalModuleReplacementPluginOptionsSVG = function (data) {
    var match = /^svg!(.*)$/.exec(data.request);
    /* eslint-disable-next-line no-param-reassign */
    data.request =
        "dojo/loaderProxy?loader=svg&deps=dojo/text%21" +
        match[1] +
        "!" +
        match[1];
};

const UnusedWebpackPluginOptions = {
    // Source directories
    directories: ["js-src/lsmb"],
    // Exclude patterns
    exclude: ["*.test.js"],
    // Root directory (optional)
    root: path.join(__dirname, "UI")
};

// Compile bootstrap module as a virtual one
const VirtualModulePluginOptions = {
    moduleName: "js-src/lsmb/bootstrap.js",
    contents:
        `/* eslint-disable */
        define(["dojo/parser","dojo/ready","` +
        includedRequires.join('","') +
        `"], function(parser, ready) {
            ready(function() {
            });
            return {};
        });`
};

// console.log(includedRequires.filter((x, i, a) => a.indexOf(x) === i).sort());

const includedRequiresContent =
    `
/* eslint-disable */
define(["dojo/parser","dojo/ready","` +
    includedRequires.filter((x, i, a) => a.indexOf(x) === i).join('","') +
    `"], function(parser, ready) {
    ready(function() {
            parser.parse();
    });
    return {};
});
`;

var pluginsProd = [
    new CleanWebpackPlugin(CleanWebpackPluginOptions),

    new ManifestPlugin(),

    new webpack.HashedModuleIdsPlugin(), // so that file hashes don't change unexpectedly

    new StatsPlugin("stats.json", {
        chunkModules: true,
        exclude: [/node_modules[\\/]dijit[\\/]themes/]
    }),

    ...htmls,

    new VirtualModulePlugin(VirtualModulePluginOptions),

    new StylelintPlugin(StylelintPluginOptions),

    new DojoWebpackPlugin(DojoWebpackPluginOptions),

    // For plugins registered after the dojo-webpack-plugin, data.request has been normalized and
    // resolved to an absMid and loader-config maps and aliases have been applied
    new webpack.NormalModuleReplacementPlugin(/^dojo\/text!/, function (data) {
        /* eslint-disable-next-line no-param-reassign */
        data.request = data.request.replace(/^dojo\/text!/, "!!raw-loader!");
    }),

    new CopyWebpackPlugin(CopyWebpackPluginOptions),

    new webpack.NormalModuleReplacementPlugin(
        /^dojo\/domReady!/,
        NormalModuleReplacementPluginOptionsDomReady
    ),

    new webpack.NormalModuleReplacementPlugin(
        /^svg!/,
        NormalModuleReplacementPluginOptionsSVG
    ),

    new ExtractCssChunks({
        filename: prodMode ? "css/[name].[contenthash].css" : "css/[name].css",
        chunkFilename: "css/[id].css",
        moduleFilename: ({ name }) => `${name.replace("js/", "js/css/")}.css`
        // publicPath: "js"
    }),

    new HtmlWebpackPlugin({
        inject: false, // Tags are injected manually in the content below
        minify: false, // Adjust t/16-schema-upgrade-html.t if prodMode is used,
        filename: "ui-header.html",
        mode: prodMode ? "production" : "development",
        excludeChunks: [...Object.keys(lsmbCSS)],
        template: "lib/ui-header.html"
    })
];

var pluginsDev = [
    ...pluginsProd,

    new UnusedWebpackPlugin(UnusedWebpackPluginOptions),

    new DuplicatesPlugin({
        // Emit compilation warning or error? (Default: `false`)
        emitErrors: false,
        // Display full duplicates information? (Default: `false`)
        verbose: false
    })
];

var pluginsList = prodMode ? pluginsProd : pluginsDev;

/* OPTIMIZATIONS */

const optimizationList = {
    moduleIds: "hashed",
    runtimeChunk: {
        name: "manifest"
    },
    namedChunks: true, // Keep names to load only 1 theme
    noEmitOnErrors: true,
    splitChunks: !prodMode
        ? false
        : {
              chunks(chunk) {
                  // exclude dijit themes
                  return (
                      chunk.name &&
                      !chunk.name.match(/(claro|nihilo|soria|tundra)/)
                  );
              },
              // maxInitialRequests: Infinity,
              cacheGroups: {
                  lsmb: {
                      test: /[\\/]lsmb[\\/]/,
                      chunks: "all",
                      minSize: 0
                  },
                  node_modules: {
                      test(module, chunks) {
                          // `module.resource` contains the absolute path of the file on disk.
                          // Note the usage of `path.sep` instead of / or \, for cross-platform compatibility.
                          return (
                              module.resource &&
                              !module.resource.endsWith(".css") &&
                              module.resource.includes(
                                  `${path.sep}node_modules${path.sep}`
                              )
                          );
                      },
                      name(module) {
                          const packageName = module.context.match(
                              /[\\/]node_modules[\\/](.*?)([\\/]|$)/
                          )[1];
                          return `npm.${packageName.replace("@", "")}`;
                      }
                  }
              }
          },
    minimize: prodMode,
    minimizer: [
        new TerserPlugin({
            parallel: process.env.CIRCLECI || process.env.TRAVIS ? 2 : true,
            sourceMap: !prodMode
        }),
        new OptimizeCSSAssetsPlugin({
            cssProcessor: require("cssnano"),
            cssProcessorOptions: {
                discardComments: { removeAll: true },
                zindex: {
                    disabled: true // Don't touch zindex
                }
            },
            canPrint: true
        })
    ]
};

/* WEBPACK CONFIG */
function _glob(pattern) {
    return [...glob.sync(pattern, { cwd: "UI" })];
}

const webpackConfigs = {
    context: path.join(__dirname, "UI"),

    entry: {
        main: "lsmb/main.js",
        bootstrap: "js-src/lsmb/bootstrap.js", // Virtual file
        "js-src_html":  _glob("js-src/**/*.html"),
        // Pull residual HTMLs
        am_html: _glob("am-*.html"),
        login_html: "login.html",
        logout_html: "logout.html",
        main_html: "main.html",
        utils_html: [
            "create_batch.html",
            "form-confirmation.html",
            "io-email.html",
            "oe-save_warn.html",
            "welcome.html"
        ],
        // Pull all HTMLs by feature. Why can't they lazy load?
        ...lsmbFeatures.reduce((result, feature) => {
            return {
                ...result,
                [feature + "_html"]: _glob(feature + "/**/*.html")
            };
        }, []),
        // CSS
        ...lsmbCSS
    },

    output: {
        path: path.resolve("UI/js"), // js path
        publicPath: "js/", // images path
        pathinfo: !prodMode, // keep source references?
        filename: "_scripts/[name].[contenthash].js",
        chunkFilename: "_scripts/[name].[contenthash].js"
    },

    module: {
        rules: [javascript, css, images, svg, html, ejs]
    },

    plugins: pluginsList,

    resolve: {
        extensions: [".js"],
        modules: ["node_modules"]
    },

    resolveLoader: {
        modules: ["node_modules"]
    },

    mode: process.env.NODE_ENV,

    optimization: optimizationList,

    performance: { hints: prodMode ? false : "warning" }
};

// console.log(webpackConfigs.entry);

/* eslint-disable-next-line no-unused-vars */
module.exports = (env) => {
    return webpackConfigs;
};
