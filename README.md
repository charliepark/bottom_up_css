# Bottom-Up CSS

## A Quick Background on Bottom-Up CSS

Most CSS organizing schemas (note: we're only talking about how the CSS file is laid out, not the logic of the CSS) are structured such that the CSS selectors are organized left-to-right. That is, you might see something like this:

    /* Base Styles */
    a{}

    /* Articles */
    div.article{}
    div.article p{}

    /* Comments */
    div.comment{}
    div.comment input{}

    /* Sidebar */
    div#sidebar{}
    div#sidebar p{}
    div#sidebar ul.local_navigation {}
    div#sidebar ul.local_navigation a{}
    div#sidebar ul.local_navigation a.current{}

    /* Footer */
    div#footer{}
    div#footer div.nav_primary a{}
    div#footer div.nav_secondary a{}

And while I can see some of the logic in grouping site modules together like that, I've found in the past that *some* sites/projects benefit from a "bottom up" approach. Although this isn't *strictly* how browsers read CSS files (specificity's a little different), it's closer than most top-down approaches.

So I'd group all of the link elements together, all of the inputs together, and so on. You'd get something more like this:

    /* a */
    a{}
    div#footer div.nav_primary a{}
    div#footer div.nav_secondary a{}
    div#sidebar ul.local_navigation a{}
    div#sidebar ul.local_navigation a.current{}

    /* div */
    div#sidebar{}
    div#footer{}
    div.article{}
    div.comment{}

    /* input */
    div.comment input{}

    /* p */
    div#sidebar p{}
    div.article p{}

    /* ul */
    div#sidebar ul.local_navigation{}

I've found that organizing my CSS in this way makes it easier to scan up and down the CSS file to find the appropriate line to change. I'm experimenting with <a href="http://smacss.com">SMACSS</a> a bit, and I've played with OOCSS, but those deal, chiefly, with the logic of the code itself, not the formatting of the CSS file.

Bottom-up CSS file layout doesn't affect your CSS rules, just the way they're layed out within the CSS file itself.

## What This Script Does

This takes an unsorted CSS file and cleans it up. Specifically, it ...

* combines identical selectors (maintaining order from original file)
* splits comma-separated selectors into their own unique lines
* cleans out comments
* cleans out unnecessary blank lines
* minimizes attributes, placing them all on one line
* orders attributes according to the bottom-up layout method
* creates a new file without modifying the original CSS

The Ruby code should be fairly straightforward to read.

## How To Use It

1. Save the file as "parser.rb" in the directory containing your CSS file.
2. In your command line client, navigate to the directory containing the parser and type in "ruby parser.rb &lt;your_css_file.css>"

The script will output the new stylesheet to "parsed_&lt;your_css_file.css>".

Alternately, you can enter the name of your CSS file on line 2 of parser.rb, and you'd only need to type in "ruby parser.rb" in the command line client.

## Things to Watch Out For

* The first line of the originating CSS file needs to be a normal line of CSS. If it's a blank line or a comment, the parser will get hung up.
* The parser currently gets hung up on @media queries, so if you have any, be sure to add them to the output CSS file "parsed_&lt;whatever>.css" manually.
* If you have any unusual usage of the "{" or "}" characters, check those selectors in the output CSS file. (For example, ".callout:before{content:'{';}".)