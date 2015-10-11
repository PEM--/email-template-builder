gulp = require 'gulp'
$ = (require 'gulp-load-plugins')()
# non-gulp
pngcrush = require 'imagemin-pngcrush'
send = require './mailer'
addMediaQueries = require './addMediaQueries'
runSequence = require 'run-sequence'
args = (require 'yargs').argv

# Paths
paths =
  jade: './jade/**/*.jade'
  jadeTemplates: './jade/templates/*.jade'
  html: './*.html'
  stylus: 'styles/**/*.styl'
  stylusIndex: './styles/styles.styl'
  css: 'styles/css/'
  images: 'images/*'
  build: './build/'

# Direct errors to notification center
handleError = ->
  $.plumber errorHandler: $.notify.onError ->
    $.util.beep()
    "Error: <%= error.message %>"

# Build
gulp.task 'plaintext', ->
  gulp.src paths.html
    .pipe $.html2txt()
    .pipe gulp.dest paths.build + '/plaintext'

# Stylus
gulp.task 'stylus', ->
  gulp.src paths.stylusIndex
    .pipe handleError()
    .pipe $.stylus()
    .pipe $.autoprefixer()
    #.pipe $.combineMediaQueries()
    .pipe gulp.dest paths.css
    .pipe $.livereload()

# Jade
gulp.task 'jade', ->
  gulp.src paths.jadeTemplates
    .pipe $.jade()
    .pipe gulp.dest './'
    .pipe $.livereload()

gulp.task 'inline', ['jade', 'stylus'], ->
  gulp.src [paths.html]
    #.pipe($.inlineCss(preserveMediaQueries: true))
    .pipe $.juice()
    .pipe gulp.dest paths.build
    .pipe $.livereload()

# Server
gulp.task 'connect', ->
  $.connect.server
    root: __dirname

gulp.task 'reload', ->
  gulp.src(paths.html).pipe $.livereload()

gulp.task 'watch', ->
  server = $.livereload()
  $.livereload.listen()
  gulp.watch paths.stylus, ['inline']
  gulp.watch paths.jade, ['inline']

gulp.task 'clean', require('del').bind(null, [
  paths.build, paths.css, paths.html
])

# Add Media Queries to Head (configure in ./addMediaQueries.coffee)
# gulp.task 'addMediaQueries', ->
#   addMediaQueries files

# Build
# gulp.task 'build', ->
#   runSequence [
#     'inline'
#     'addMediaQueries'
#   ]
# gulp.task 'build', ->
#   runSequence [
#     'inline'
#     'addMediaQueries'
#   ]

# --------------------------------------------------------
# SEND EMAIL (configure in ./mailer.coffee)
# --------------------------------------------------------
# Files to email
# files = [
#   "index.html"
# ]
#
# filename = args.file
# gulp.task "send", ->
#   send(filename)
#
# gulp.task "sendAll", ->
#   i = 0
#   while i < files.length
#     file = files[i].split(".")
#     send(file[0])
#     i++


# --------------------------------------------------------
# Connect to server
# --------------------------------------------------------
gulp.task 'default', [
  'inline'
  'connect'
  'watch'
]
