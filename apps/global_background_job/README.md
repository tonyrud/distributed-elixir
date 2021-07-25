# GlobalBackgroundJob

Starts a distributed singleton process. Add any number of instances, and only one will be running the task in a timeout loop.

## Starting nodes

Terminal 1

```bash
iex --name n1 -S mix
```

Terminal 2

```bash
iex --name n2 -S mix
```

There will only be one process running in global registry

```bash
:global.registered_names
```

Find the process pid

```bash
:global.whereis_name GlobalBackgroundJob.DatabaseCleaner
```
