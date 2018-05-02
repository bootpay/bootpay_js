export default Logger =
  logLevel: 1
  setLogLevel: (level) ->
    switch level
      when 1 # production
        @logLevel = 1
      when 2 # Warning
        @logLevel = 2
      when 3 # Info
        @logLevel = 3
      else
        @logLevel = 4

  debug: (msg) -> console.log msg if @logLevel >= 4
  info: (msg) -> console.info msg if @logLevel >= 3
  warn: (msg) -> console.warn msg if @logLevel >= 2
  error: (msg) -> console.error msg if @logLevel >= 1