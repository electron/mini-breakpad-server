module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffee:
      glob_to_multiple:
        expand: true
        cwd: 'src'
        src: ['*.coffee']
        dest: 'lib'
        ext: '.js'

    coffeelint:
      options:
        max_line_length:
          level: 'ignore'

      src: ['src/**/*.coffee']

    watch:
      express:
        files: ['**/*.coffee']
        tasks: ['express:dev']
        options:
          spawn: no

    express:
      dev:
        options:
          opts: ['node_modules/coffee-script/bin/coffee']
          cmd: process.argv[0]
          script: 'src/app.coffee'

  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-express-server')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-shell')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.registerTask('lint', ['coffeelint'])
  grunt.registerTask('default', ['coffee', 'lint'])
  grunt.registerTask 'clean', ->
    rm = require('rimraf').sync
    rm('lib')
  grunt.registerTask('serve', ['express', 'watch'])
