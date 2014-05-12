docpad-plugin-urlnorm
=====================

** Not ready for release **

URL normalizer for DocPad

1. Rename your output files to normalized names. You can still serve with static servers such as `nginx` or `apache`.
2. Change all <a href=''></a> tags in .html output accordingly.

Have a freedom to name your raw files as you want.
You have consistent urls and no need to remember puncuations.

## Example

```
src/documents/Fruit/Red Apple.html
Original  : http://www.example.com/Fruit/Red%20Apple.html
Normalized: http://www.example.com/fruit/red-apple.html
```

## Options

This is the default setting.

```json
plugins:
	urlnorm:
		enable: true

		documentPath: ['/']
		assetPath: ['/']       # you can normalize even asset and layout files
		layoutPath: ['/']

		normalizeDirs: true
		capitalizeDirs: true  # aaa/bBb/cCc.html -> Aaa/Bbb/cCc.html. Used when normalizeDirs == true
		normalizeFiles: true
		capitalizeFiles: false # aaa/bBb/cCc.html -> aaa/bBb/Ccc.html. Used when normalizeDirs == true

		mapping:
			' ':'-',           # ' ':'' to just remove spaces
			'/':null           # use null to throw error to prevent silent failures

		normalizeLinks: true   # <a href='Projects'> -> <a href='projects'>
		errorOnConflicts: true # 'A B C.html.md' vs 'a-b-c.html.eco'
```

## TODO
* Normalize assets and layouts