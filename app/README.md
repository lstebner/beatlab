# Application Howto's

There is a lot of things provided in the "app" here so I will attempt to explain them all for reference. Mostly as a list of how to's for things such as adding new views or data models. 

## Initial Setup

The first thing you'll probably have to do is the initial setup. This involves mostly file naming and a few edits within files or removal of things you don't want. 

### Create a new "gitignore" file

Ignore:
- .gitignore
- *.codekit
- *.conf
- .DS_Store

### Files

- /app folder: The root app folder. You'll want to add/remove from the helpers, controllers and views folders as meets the needs for your app. 
- [your_app_name].coffee: This should define your custom App. I typically also define a Query object and custom base Controller though these could be in separate files if you want. 
- app.coffee: Append your custom app file here and pass it into the App.init
- declaration.coffee: Create your base object in here. This is kinda lame, but due to how Codekit does file append/prepend it ensures this object exists at the beginning.

- /app/conf: Update the settings in these files to reflect your app
- /app/public/includes: There are some basic resources available you can include from here
