#### Unreleased
* Update MIT license copyright holder
  > emmahsax: https://github.com/emmahsax/okcomputer/pull/10
* Added `bin/release` script to make it easier to make new version bumps and releases without other tools like soyuz or octopolo
  > emmahsax: https://github.com/emmahsax/okcomputer/pull/8
* Fix rspec tests and add testing for higher versions of Ruby/Rails
  > emmahsax: https://github.com/emmahsax/okcomputer/pull/9

#### v1.18.6
* Change default branch from `master` to `main`
  > emmahsax: https://github.com/emmahsax/okcomputer/pull/7
* Update gemspec metadata
  > rmm5t: https://github.com/emmahsax/okcomputer/pull/6

#### v1.18.5
* Add tests for rails 7
  > cbeer: https://github.com/sportngin/okcomputer/pull/174
* Fix cache typo for GenericCacheCheck
  > rmm5t: https://github.com/sportngin/okcomputer/pull/175
* Various other changes

#### v1.17.4
* Update check times to display fractional seconds
  > stevendaniels: https://github.com/sportngin/okcomputer/pull/155

#### v1.17.3
* Update the built-in SolrCheck for compatibility with Solr 7+
  > cbeer: https://github.com/sportngin/okcomputer/pull/151

#### v1.17.2
* Add Support for Rails 5.2 Migration Check
  > rmm5t: https://github.com/sportngin/okcomputer/pull/147

#### v1.17.1
* Check name in CheckCollection#Register
  > elliott-beach: https://github.com/sportngin/okcomputer/pull/141

#### v1.17.0

* Allow optional logging through `OkComputer.logger`. Enable by providing a configured logger to `OkComputer.logger=`.

#### v1.16.0

* Add a Resque Scheduler check
  > agacode: https://github.com/sportngin/okcomputer/pull/134

#### v1.15.0

* Add a SequelCheck
  > Aryk: https://github.com/sportngin/okcomputer/pull/136

#### v1.14.2

* Fix exception which can occur when using both symbols and strings when registering checks.

#### v1.14.1
* Add new check to determine whether the app has pending ActiveRecord migrations.
  > pcboy, pbyrne: https://github.com/sportngin/okcomputer/pull/127

#### v1.14.0
* Add check collections to OkComputer
  > newzac, Andy Fleener: Coveralls, Unknown User: https://github.com/sportngin/okcomputer/pull/124

#### v1.13.0

* Include type of cache in the cache check output.
* Add new check to determine whether server configuration by ActionMailer is responding.
* Add new check to determine whether given directory is available on the filesystem.

#### v1.12.0

* Syntax change for better compatibility with legacy Ruby 1.9 applications.

#### v1.11.1

* Fix deprecation warning with useage of Kernal#timeout

#### v1.11.0

* Adds the ability to specify particular checks are optional. They will still display as failed if they fail, but the HTTP response will still be successful.
* Adds the execution time of each check to the response (in seconds).

#### v1.10.0

* Allow customizing the plain-text output through Rails' internaltionalization. See README for details.

#### v1.9.1

* Allow CacheCheck to work with Rails cache stores which don't have a `#stats` method, like the filesystem cache.

#### v1.9.0

* Added support for Rails 5!
* Updated CI build matrix (and consequently, added/dropped official support of Ruby/Rails versions)
  * Dropped support for Rails 4.0, Ruby 2.0 (EOL)
  * Added Rails 5.0 and Ruby 2.2, 2.3
  * Current supported versions are now Rails 5.0, 4.2, 4.1, 3.2, and Ruby 2.1, 2.2, 2.3

#### v1.8.0

* No longer display name of requested check when no matching check is found. This eliminates possibility of XSS vulnerability with maliciously crafted requests.
  * Before: "No check registered with 'CHECK_NAME'"
  * After: "No matching check"

#### v1.7.3

* Adds support for Neo4j

#### v1.7.2

* Only apply basic auth headers for HTTP checks when basic auth credentials are configured.

#### v1.7.1

* Add Support for basic auth on http checks

#### v1.7.0

* Add RabbitmqCheck check to test your RabbitMQ connection.

#### v1.6.6

* Reduce Rails dependencies outside of the engine. The upshot is OK Computer is now easier to port to non-Rails apps.

#### v1.6.5

* Add `okcomputer_check` and `okcomputer_checks` names to existing routes. Now you can `link_to okcomputer_checks` or otherwise refer to them programmatically.

#### v1.6.4

* Added support for Mongoid 5

#### v1.6.3
* Added support for Sidekiq 4

#### v1.6.2

* Fix exception when requiring `okcomputer` without the use of Bundler.

#### v1.6.1

* Add built in redis health check

#### v1.6.0

* Added a configuration option to run checks in parallel.

#### v1.5.1
#### v1.5.0

* Added new options to DelayedJobBackedUpCheck: which queue to check, whether to include running jobs in the count, whether to include failed jobs in the count, and a minimum priority of jobs to count.
* Updated MongoidCheck for compatibility with Mongoid 5.

#### v1.4.0

* Added two new checks:
  * SolrCheck, which tests connection to a Solr instance
  * HttpCheck, which tests connection to an arbitrary HTTP endpoint
* ElasticsearchCheck has been modified to be a child of HttpCheck, with no change in external behavior.

#### v1.3.0

* MongoidCheck now accepts an optional `session` argument to check the given session.

#### v1.2.0

* Added two new checks:
  * ElasticsearchCheck, which tests the health of your Elasticsearch cluster
  * AppVersionCheck, which reports the version (as a SHA) of your app is running

#### v1.1.0

* Added two new checks:
  * GenericCacheCheck, which tests that `Rails.cache` is able to read and write.
  * MongoidReplicaSetCheck, which tests that all of your configured Mongoid replica sets can be reached.
* Modified CacheCheck to accept an optional Memcached host to test. The default behavior of testing Memcached on the local machine remains unchanged.

#### v1.0.0

* Version bump
* For prior breaking changes from initial development, see [the Deprecations and Breaking Changes section](https://github.com/emmahsax/okcomputer/blob/3f6708b333ddaf7ecc14d8c2b163335d46343f66/README.markdown#deprecations-and-breaking-changes) of the pre 1.0 README.
