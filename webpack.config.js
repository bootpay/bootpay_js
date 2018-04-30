const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const version = require('./package.json').version;
module.exports = {
    entry: './lib/bootpay.coffee',
    output: {
        path: __dirname + '/dist',
        filename: "bootpay-" + version + "-min.js"
    },
    resolve: {
        extensions: ['.js', '.css', '.sass', '.coffee', '.json']
    },
    devServer: {
        port: 3001,
        public: 'g-cdn.bootpay.co.kr'
    },
    optimization: {
        minimizer: [
            new UglifyJsPlugin({
                cache: true,
                parallel: true,
                uglifyOptions: {
                    compress: true,
                    ecma: 6,
                    mangle: true
                },
                sourceMap: true
            })
        ]
    },
    module: {
        rules: [
            {
                test: /\.coffee(\.erb)?$/,
                use: [{
                    loader: 'coffee-loader',
                    options: {
                        // literate: true,
                        transpile: {
                            presets: ['es2015']
                        }
                    }
                }]
            },
            {
                test: /\.css/,
                use: [{
                    loader: "css-loader" // translates CSS into CommonJS
                }]
            },
            {
                test: /\.sass$/,
                use: [{
                    loader: "style-loader" // creates style nodes from JS strings
                }, {
                    loader: "css-loader" // translates CSS into CommonJS
                }, {
                    loader: "sass-loader" // compiles Sass to CSS
                }]
            }
        ]
    }
};