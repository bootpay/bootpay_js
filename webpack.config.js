module.exports = {
    entry: './lib/bootpay.coffee',
    output: {
        path: __dirname,
        filename: 'bootpay-latest.js'
    },
    resolve: {
        extensions: ['.js', '.css', '.sass', '.coffee', '.json']
    },
    devServer: {
        port: 3001
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