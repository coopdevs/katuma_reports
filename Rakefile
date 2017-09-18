#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

KatumaReports::Application.load_tasks

# Disable all write rake tasks so that we don't mess up the OFN's database
Rake::Task['db:migrate'].clear
Rake::Task['db:create'].clear
Rake::Task['db:drop'].clear            # Drops the database using DATABASE_URL or the current Rails.env (use db:drop:all to drop all databases)
Rake::Task['db:fixtures:load'].clear   # Load fixtures into the current environment's database
Rake::Task['db:migrate'].clear         # Migrate the database (options: VERSION=x, VERBOSE=false)
Rake::Task['db:rollback'].clear        # Rolls the schema back to the previous version (specify steps w/ STEP=n)
Rake::Task['db:schema:load'].clear     # Load a schema.rb file into the database
Rake::Task['db:setup'].clear           # Create the database, load the schema, and initialize with the seed data (use db:reset to also drop the db first)
