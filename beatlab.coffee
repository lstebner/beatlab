# @codekit-prepend "app/core/_main"
# @codekit-append "app/views/__index"
# @codekit-append "app/controllers/__index"

# @codekit-prepend "beatlab/beats_data"
# @codekit-prepend "beatlab/app"
# @codekit-prepend "beatlab/query"
# @codekit-prepend "beatlab/controller"


HUSH_LOG = 0
__log = (args...) ->
  console.log(args...) unless HUSH_LOG 

fs = require("fs")
beats_data_raw = fs.readFileSync("./beats_data.txt", "UTF-8").trim()

beats_data = new BeatsData beats_data_raw




