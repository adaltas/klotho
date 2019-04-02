templated = require('..');
// Render
config = templated({
  "webapp": {
    "app_name": 'cool_app',
    "db_url": 'mysql://{{db.host}}:{{db.port}}/{{webapp.db_name}}',
    "db_name": 'db_{{webapp.app_name}}'
  },
  "db": {
    "host": 'localhost',
    "port":  '3306'
  }
});
// Assert
console.log(config.webapp.db_url == "mysql://localhost:3306/db_cool_app");
