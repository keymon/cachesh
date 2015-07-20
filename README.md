# cachesh

This is a wrapper command to cache the output, stderr and exit code of
any random command.

The purpose is speed up executions of scripts, bootstraps, common tasks, etc.

## Usage

```
cachesh <command> [args]
```

Check `cachesh.sh` for environment variables

## Features

This is still in progress. I want to implement all these features, but I'm
not in a hurry.

Requirements:

 * In bash: must be portable, not require dependencies
 * Cross platform support: MacOSX, linux, cygwin?
 * Fast and transparent

I want to implement the following features:

 * ~~Cache any command stdout/stderr/exit using arguments as key~~
 * Customize TTL
 * Allow execute more complex expressions.
   * e.g: `command_x | sort | uniq -c`
 * Alternative keys and invalidations (customizable by options):
   * Use only the command path
   * environment variables
   * check if update is required with external command
 * Implement as much as possible using built-in functions to increase performance
 * List existing cached objects keys
 * Option to force update
 * Functions to invalidate cache
   * Using command, wildcards, etc.
   * Garbage collection: clean up old stuff
 * Keep output order of the stdout/stderr
 * Optionally report to the user when is cached or not cached version
 * Integrate this with bash-it: Speed up bash-it commands.
 * Find and include absolute command path when computing the key
 * Support to run as a symbolic link. For example:
   ```
mv /usr/local/bin/slow_program /usr/local/bin/slow_program.cachesh
ln -s /usr/local/bin/cachesh /usr/local/bin/slow_program
```


## Notes and Questions

 * Q: Is SHA256 enough?
 * A: [This stackoverflow answer](http://stackoverflow.com/questions/4014090/is-it-safe-to-ignore-the-possibility-of-sha-collisions-in-practice/4014407#4014407) by [Thomas Pornin](http://stackoverflow.com/users/254279/thomas-pornin) gives a great response to that :)


## References/Credits

 * I got the idea from here: http://stackoverflow.com/questions/11900239/can-i-cache-the-output-of-a-command-on-linux-from-cli

