# Export Plugin
module.exports = (BasePlugin) ->
    fs = require('fs')
    cheerio = require('cheerio')
    _ = require('underscore')

    # *** Helpers ***
    String.prototype.replaceBetween = (start, end, what) ->
        this.substring(0, start) + what + this.substring(end)

    config =
        exceptions: ['index.html', 'robot.txt']
        normalizeDirs: true
        capitalizeDirs: true  # aaa/bBb/cCc.html -> Aaa/Bbb/cCc.html. Used when normalizeDirs == true
        normalizeFiles: true
        capitalizeFiles: true # aaa/bBb/cCc.html -> aaa/bBb/Ccc.html. Used when normalizeDirs == true

        mapping:
            ' ':'-',           # ' ':'' to just remove spaces
            '/':null           # use null to throw error to prevent silent failures


        # TODO
        enable: true
        documentPath: ['/']
        assetPath: ['/']       # you can normalize even asset and layout files
        layoutPath: ['/']
        errorOnConflicts: true # 'A B C.html.md' vs 'a-b-c.html.eco'

    normalizeName = (name, capitalize, maps) ->

        nname = ''
        prev = false
        for i in [0...name.length]
            chr = name.charAt i
            if (chr>='a' and chr<='z') or (chr>='A' and chr<='Z')
                if prev or !capitalize
                    nname += chr.toLowerCase()
                else
                    nname += chr.toUpperCase()
                prev = true
            else
                if chr of config.mapping
                    if config.mapping[chr]
                        nname += config.mapping[chr]
                    else
                        throw new Error("[docpad-plugin-urlnorm] forbides the character '"+chr+"' in names of source files.")
                else
                    nname += chr
                prev = (chr=='.')
        nname

    normalize = (path) ->
        if path.indexOf('://')==-1 # relative path
            list = path.split('/')
            fileName = list.pop()
            if fileName in config.exceptions
                return path

            if config.normalizeFiles
                fileName = normalizeName(fileName, config.capitalizeFiles, config.mapping)
            if config.normalizeDirs
                list = _.map(list, (dirName) ->
                    normalizeName(dirName, config.capitalizeDirs, config.mapping)
                )

            list.push(fileName)
            list.join('/')
        else # absolute path
            path

    # Define Plugin
    class UrlNormPlugin extends BasePlugin
        # Plugin name
        name: 'urlnorm'

        renderBefore: (opts) ->
            c = @docpad.getCollection("documents")
            outRoot = @docpad.config.outPath
            c.forEach (document) ->
                path = document.get('relativeOutPath')
                document.setMeta('outPath', outRoot + "/" + normalize(path))
            @

        renderDocumentPriority: 400 # should run after all the placeholders in html are processed

        renderDocument: (opts, next) ->
            {extension, file, content} = opts

            if file.type is 'document' and extension is 'html'
                $ = cheerio.load(content)
                $('a').each( (i,element) ->
                    if href = $(this).attr('href')
                        $(this).attr('href', normalize(href) )
                )
                $('img').each( (i,element) ->
                    if src = $(this).attr('src')
                        $(this).attr('src', normalize(src) )
                )
                opts.content = $.html()

            next()