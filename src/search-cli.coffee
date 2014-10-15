path = require 'path'

Q = require 'q'

log = require 'verbalize'
program = require 'commander'

KSSIndex = require './index'


packageJSON = require path.join(__dirname, "..", "package.json")

program
    .version packageJSON.version

program
    .description 'searech kss documented sass stylesheets'
    .option '-index, --index [index]', "input file for the index (defaults to #{KSSIndex.DEFAULT_INDEX_FILE}"


program.parse(process.argv)

query = program.args.join ' '

log.info "Searching for: #{query}"

indexDB = KSSIndex.load(program.index)
result = indexDB.search query
console.log result
