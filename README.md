[![forthebadge](http://forthebadge.com/images/badges/no-ragrets.svg)](http://forthebadge.com)

Urda's Bash Files
========================================================================================================================

This is a collection of my bash prompt settings, aliases, exports, and more.

Bootstrapping urda.bash
------------------------------------------------------------------------------------------------------------------------

If you are configuring a new shell, or you do not care if your `.bash*` files are overwritten,
you can use the following command to download the files from the project:

**/!\ WARNING /!\** This is a destructive operation to your `.bash*` files!

```bash
bash <(curl -s https://raw.githubusercontent.com/urda/urda.bash/master/bootstrap-urda.bash.sh)
```

Comparing to your local bash
------------------------------------------------------------------------------------------------------------------------

You can also run a quick `diff` that will compare GitHub against your local `bash` files.

```bash
bash <(curl -s https://raw.githubusercontent.com/urda/urda.bash/master/show-github-diffs.sh)
```
