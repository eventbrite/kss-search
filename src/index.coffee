fs = require 'fs'

Q = require 'q'
lunr = require 'lunr'
kss = require 'kss'


DEFAULT_INDEX_FILE = "kss-index.json"


class KSSIndex
    DEFAULT_INDEX_FILE: DEFAULT_INDEX_FILE
    constructor: ->
        @index = lunr ->
            @ref 'section'
            @field 'header', boost: 10
            @field 'section', boost: 20
            @field 'description'

    indexSection: (section) ->
        @index.add
            section: section.reference()
            header: section.header()
            desription: section.description()
        console.log "indexed #{section.reference()}"

    indexFiles: (path) ->
        console.log path
        Q.nfcall kss.traverse, path, {}
        .then (response) =>
            response.data.sections.forEach (section) =>
                @indexSection section

    search: (query) ->
        @index.search query

    save: (destination) ->
        destination = destination or DEFAULT_INDEX_FILE
        Q.nfcall fs.writeFile, destination, JSON.stringify(@index.toJSON())

    @load: (data) ->
        index = new @()
        index.index = lunr.Index.load(JSON.parse(data))
        return index

    @loadFile: (source) ->
        source = source or DEFAULT_INDEX_FILE
        data = fs.readFileSync source
        @load data

module.exports = KSSIndex
