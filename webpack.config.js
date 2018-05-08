const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
module.exports = {
    entry: './lib/bootpay.coffee',
    output: {
        path: __dirname,
        filename: "bootpay-latest.js"
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
                uglifyOptions: {
                    compress: true,
                    ecma: 5,
                    mangle: true,
                    output: {
                        comments: false,
                        beautify: false
                    },
                    cache: true,
                    parallel: true,
                    sourceMap: (process.env.MODE_ENV !== 'production')
                }
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
                use: ['style-loader', 'css-loader']
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