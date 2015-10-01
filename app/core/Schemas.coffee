App.Schemas = {}
{Schema} = Requires

App.Schemas.Project = new Schema {
  title: type: String, required: true
  order: type: Number, default: 0
  slug: type: String, require: true, unique: true
  description: type: String, default: ""
  display_url: type: String, default: ""
  full_url: type: String, defalut: ""
  technologies: type: Schema.Types.Mixed, default: []
  images: type: Schema.Types.Mixed, default: []
  archived: type: Boolean, default: false
  group: type: String, default: "default"
}

