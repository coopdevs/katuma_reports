# Katuma Reports

Katuma reports is a simple Rails app the generates reports of an [Open Food
Network]() application. It reads data from an open food network's database and
displays meaningful reports out of it.

## Installation

You must define the `OFN_MAIN_APP_BASE_URL` env var with the root URL of the
Open Food Network app. That is, the app Katuma reports is going to build
reports for. Note the URL must contain the protocol as well.

You would use something like the following for development:

```shell
export OFN_MAIN_APP_BASE_URL="http://localhost:3000"
```

First install the dependencies:

```shell
$ bundle install
```

Katuma Reports reads the session data of the OFN app and so you must log in on
it first. To that end OFN must be up and running. In development environment
boot the server with:

```shell
$ bundle exec rails server
```

This will make OFN's server listen to the port 3000. You should now log in. Once
done we can finally start Katuma reports in a different port:

```shell
$ bundle exec rails server -p 4000
```

All orders placed through the OFN app will be 

## Architecture

Besides sharing the database access, Katuma reports does also share user
sessions with the OFN app. That is possible due to fact OFN uses server-side
sessions. Katuma reports reads the session id present in the cookie to retrieve
the session hash from the OFN's database. That implies:

* Katuma reports needs read access to the OFN's database
* You must log in/out to OFN to create or destroy your session

That is why Katuma reports redirects to the OFN app on authentication failure.
