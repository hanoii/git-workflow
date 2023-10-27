# A Git Workflow

The goal of this workflow is to have a cleaner history, makes things easier to
review when you go back in time. In general there’s nothing too complex, but it
includes rebasing, which if not done right and with care can cause loss of work.
It’s gotten a lot better and there are ways to still recover the work, so I am
less worried, but the warning is still there.

One way of explaining rebases is thinking them as `.patch` files. Imagine each
of the commits you are rebasing is a `.patch` file and you apply that patch file
one after the other on top of a a new codebase. Each patch will then create a
new commit.

Normally, the `.patch` applies clean, but as you probably encountered it
sometimes fails to apply cleanly. This is when you will put your surgeon cap
knife and work carefully. It’s pretty much the same as sorting out merge
conflicts, but a merge commit is more easily revertable. The other problem with
rebases is that it might require you to force-push, which is again dangerous,
but in this workflow you would only force-pushing to the feature branch you are
working on and about to merge, so not a huge deal.

<!-- toc -->

- [Pull rebase keeping merges](#pull-rebase-keeping-merges)
- [Production/Staging branches](#productionstaging-branches)
- [Pull requests/feature branches](#pull-requestsfeature-branches)
- [Hotfixes to Production](#hotfixes-to-production)
- [Optional squashing](#optional-squashing)
- [Commit messages](#commit-messages)

<!-- tocstop -->

## Pull rebase keeping merges

TL;DR

- `git pull --rebase-merges`
- `git config --global pull.rebase merges`

This will fetch whatever is in the remote and re-apply your local commits on top
of the new code. This is to get rid of the remote merge commits.

The `merges` option keeps your local merge commits, if any. This is to prevent
accidentally dropping those on the master/staging branches.

Because this is just a rebase of your local, no force push is necessary.

Conflicts can happen so you can either fix, commit and continue the rebase
(`git rebase --continue`) or abort it (`git rebase --abort`) and go back to
pulling normally if you want to be cautions: `git pull --merge`.

You can try it out and then configure as your default for every project with git
config `--global pull.rebase true`.

## Production/Staging branches

**Staging should at all times be deployable to Production.**

TL;DR

- `git checkout master`
- `git pull`
- `git merge staging --ff-only`

A common scheme is having at least one production branch (`master`, `main`, etc)
and a staging branch (`stage`, `staging` , `develop`) that’s always where code
lands that will soon be merged onto the Production branch.

As the history between staging and production should ideally be always the same,
having a merge commit on master from staging makes no sense. To avoid this you
should normally merge with `--ff-only` which does a fast-forward. If this fails
is because the history of the production branch diverged and we need to fix
accordingly.

You can configure this globally by doing
`git config --global branch.master.mergeOptions --ff-only` for master and
`git config --global branch.main.mergeOptions --ff-only` for main.

## Pull requests/feature branches

**Assumes PR/feature branches are off a Staging branch branch named `staging`.**

**PR, feature/branches are short-lived, they must be removed once the work is
merged.**

TL;DR - when you are ready to merge the PR/feature/branch

- `git checkout staging`
- `git pull`
- `git checkout feature/branch`
- `git rebase staging` (can cause conflicts which you’ll need to fix)
- `git push --force-with-lease`
- `git checkout staging`
- `git merge --no-ff feature/branch`
- `git push`
- `git push origin :feature/branch` (removes remote branch)
- `git branch -d feature/branch` (removes local branch)

If we merge PR/feature branches as is, a bunch of PR/feature branches can be
with commits happening in different times. While this is OK, it' gives a much
clearer history graph if we rebase first. Further more, rebasing loses the merge
commits that we might have while keeping the feature/branch up to date, which
are also not important.

This should be done at the last step just before merging the branch to staging,
which is specially important if the feature/branch is being worked on by
different developers.

You should `git push --force-with-lease` your rebased code to the remote
PR/feature branch just before merging.

You can then proceed and checkout to your staging branch and merge your
PR/feature branch with `git merge --no-ff feature/branch`. The --no-ff is meant
to store a merge commit of the PR/feature branch so that the history can still
be accessed.

**Note: PR/feature branch are to be short-lived, so make sure you remove the
remote (`git push origin :feature/branch`) and local PR/feature branch
(`git branch -d feature/branch`).**

## Hotfixes to Production

To be documented, but keeping master/staging with the exact same history is the
most important key element.

## Optional squashing

I am not a fan of squashing, but used with common sense it can be helpful. If
your feature branch is full of small commits that touches very little
files/lines, it makes more sense to squash them than merge the whole history.

TL;DR

- `git checkout staging`
- `git merge feature/branch --squash` (there’s no commit here yet, but changes
  are staged)
- `git commit -m "JIRA-1234: something done"` (JIRA-1234 or whatever references
  your PM tool of choice)
- `git push`
- `git push origin :feature/branch` (removes remote branch)
- `git branch -d feature/branch` (removes local branch)

## Commit messages

Textual from https://github.blog/2011-09-06-shiny-new-commit-styles/:

**Always include a reference to the task (Jira, Trello, clickup) in the summary
or the description.**

**If at all possible look for integration between the PM tool and the commit.**

```
Capitalized, short (50 chars or less) summary

More detailed explanatory text, if necessary. Wrap it to about 72 characters or
so. In some contexts, the first line is treated as the subject of an email and
the rest of the text as the body. The blank line separating the summary from the
body is critical (unless you omit the body entirely); tools like rebase can get
confused if you run the two together.

Write your commit message in the present tense: "Fix bug" and not "Fixed bug."
This convention matches up with commit messages generated by commands like git
merge and git revert.

Further paragraphs come after blank lines.

- Bullet points are okay, too
- Typically a hyphen or asterisk is used for the bullet, preceded by a single
  space, with blank lines in between, but conventions vary here
- Use a hanging indent
```
