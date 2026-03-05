# Decidim::BudgetsBooth

The purpose of this module is to improve the budgeting voting process to help
users to focus on the primary action and hide all the irrelevant information and
distractions from the user that may lead to the user not understanding that
their vote has not been cast. The idea is to "lock" the user inside a voting
booth during the voting process and make it extremely clear for them that if
they exit the voting booth, they have not yet cast their vote.

This module also provides design improvements on the projects index view, like
the possibility in this view to switch between grid mode and list mode
(default is grid mode).

## Usage

This module is built on top of the `decidim-budgets` module and adds extra
feature/capabilities to it. After installing this module, the normal budgeting
component will automatically provide the voting booth capabilities meaning if
you do not want these capabilities, you should uninstall this module.


This module enables the following features to the budget voting experience:

- Defining cancel and after finishing voting redirection destinations.
  * Useful for asking for feedback, for example, after completing voting.
- Introducing a new configuration for maximum number of budgets, in which users
  can vote.
- Adding after voting and after completing voting message, configurable from
  admin panel.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-budgets_booth", github: "Pipeline-to-Power/decidim-module-ptp", branch: "main"
```

And then execute:

```bash
bundle
```

## Configuration

### Admin configuration

You can configure the following options from your budgets component configurations:

- **Popup text after each vote**: the content of the popup which is being shown
  after each voting.
- **Popup text after voting in all available budgets**: the content of the popup
  which is being shown after user voted in all available budgets.
- **URL to redirect user after voting on all available budgets**: Defines where
  user is redirected after completing their vote.
  * By default, the user is redirected back to the budgets list.
- **URL to redirect user when canceling voting**: Defines where the user is
  redirected if they decide to cancel the voting process.
  * By default, the user is redirected to the root path.
- **Maximum number of budgets that user can vote on**: Defines how many budgets a user can vote on. 
  * By default, the value is 0, which means user can vote on all available budgets.


## Testing

To run the tests, run the following in the gem development path:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

## Test code coverage

If you want to generate the code coverage report for the tests, you can use
the `SIMPLECOV=1` environment variable in the rspec command as follows:

```bash
$ SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named `coverage` in the project root which contains
the code coverage report.
