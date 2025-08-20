<!-- #ddev-generated -->
The idea for directory is to provide a way for another addons to register hook 
scripts. This is very similar to adding it to config.yaml, only that this exists
so that this scripts can be called from within ddev itself. For now this makes
sense for post-import-db hooks were one might have a locally defined import 
method and/or script.
