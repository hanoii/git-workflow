# A Git Workflow

The goal of this workflow is to have a cleaner history, which makes things
easier to review when you go back in time. In general, there's nothing too
complex, but it includes rebasing, which if not done right and with care can
cause loss of work. It's gotten a lot better and there are ways to still recover
the work, so I am less worried, but the warning is still there.

One way of explaining rebases is thinking of them as `.patch` files. Imagine
each of the commits you are rebasing is a `.patch` file and you apply that patch
file one after the other on top of a new codebase. Each patch will then create a
new commit.

Normally, the `.patch` applies cleanly, but as you have probably encountered, it
sometimes fails to apply properly. This is when you will put on your surgeon's
cap and work carefully. It's pretty much the same as sorting out merge
conflicts, but a merge commit is more easily revertible. The other problem with
rebases is that they might require you to force-push, which is again dangerous,
but in this workflow you would only be force-pushing to the feature branch you
are working on and about to merge, so it's not a huge deal.

<!-- prettier-ignore -->
> [!TIP]
> All the git configurations mentioned in this workflow
> are available in [`example.gitconfig`](example.gitconfig). Copy the settings
> to your `~/.gitconfig` or run the equivalent `git config --global` commands.

<!-- toc -->

- [Pull rebase keeping merges](#pull-rebase-keeping-merges)
- [Production/Staging branches](#productionstaging-branches)
- [Pull requests/feature branches](#pull-requestsfeature-branches)
  * [`--force-with-lease` and `--force-if-includes`](#--force-with-lease-and---force-if-includes)
- [Rebasing](#rebasing)
- [Pull request review](#pull-request-review)
- [Hotfixes to production](#hotfixes-to-production)
- [Optional squashing](#optional-squashing)
- [Commit messages](#commit-messages)

<!-- tocstop -->

## Pull rebase keeping merges

TL;DR

- `git pull --rebase-merges`

<!-- prettier-ignore -->
> [!TIP]
> You can configure this as your default pull behavior with
> `git config --global pull.rebase merges`

This will fetch whatever is in the remote and reapply your local commits on top
of the new code. This eliminates unnecessary remote merge commits.

The `merges` option keeps your local merge commits, if any. This prevents
accidentally dropping those on the `main`/`staging` branches.

Because this is just a rebase of your local commits, no force push is necessary.

Conflicts can happen, so you can either fix them, commit, and continue the
rebase (`git rebase --continue`) or abort it (`git rebase --abort`) and go back
to pulling normally if you want to be cautious: `git pull --merge`.

## Production/Staging branches

**Staging should at all times be deployable to Production.**

TL;DR

- `git checkout main`
- `git pull`
- `git merge staging --ff-only`

<!-- prettier-ignore -->
> [!TIP]
> You can configure this globally with
> `git config --global branch.main.mergeOptions --ff-only` (sets the default merge
> strategy for the `main` branch).

A common scheme is having at least one production branch (`main`) and a staging
branch (`stage`, `staging`, `develop`) that's always where code lands before
being merged onto the production branch.

Since the history between staging and production should ideally always be the
same, having a merge commit on `main` from `staging` makes no sense. To avoid
this, you should normally merge with `--ff-only`, which performs a fast-forward.
If this fails, it's because the history of the production branch has diverged
and needs to be fixed accordingly.

## Pull requests/feature branches

**Assumes PR/feature branches are created from a staging branch named
`staging`.**

**PR/feature branches are short-lived; they must be removed once the work is
merged.**

TL;DR - when you are ready to merge the PR/feature branch

- `git checkout staging`
- `git pull`
- `git checkout feature/branch`
- `git rebase staging` (can cause conflicts which you'll need to fix)
- `git push --force-with-lease --force-if-includes`
- `git checkout staging`
- `git merge --no-ff feature/branch`
- `git push`
- `git push origin :feature/branch` (removes remote branch)
- `git branch -d feature/branch` (removes local branch)

<!-- prettier-ignore -->
> [!TIP]
> You can configure safer force-pushing as the default with
> `git config --global push.useForceIfIncludes true` (automatically adds
> `--force-if-includes` when `--force-with-lease` is used).
>
> Note: there's currently no configuration to make `--force-with-lease` the
> default for pushes.

<!-- prettier-ignore -->
> [!TIP]
> You can also configure no-fast-forward merges as the default with
> `git config --global merge.ff false` (sets `--no-ff` as the default merge
> strategy for all branches).
>
> Note: we've already configured `main` to use `--ff-only` when merging into it,
> which is more restrictive and takes precedence for that specific branch.

If we merge PR/feature branches as-is, multiple PR/feature branches can have
commits happening at different times. While this is acceptable, it gives a much
clearer history graph if we rebase first. Furthermore, rebasing removes the
merge commits that we might have accumulated while keeping the feature branch up
to date, which are not important for the final history.

This should be done as the last step just before merging the branch into
staging, which is especially important if the feature branch is being worked on
by multiple developers.

You should push your rebased code to the remote PR/feature branch with
`git push --force-with-lease --force-if-includes` just before merging.

You can then check out your staging branch and merge your PR/feature branch with
`git merge --no-ff feature/branch`. The `--no-ff` flag creates a merge commit
for the PR/feature branch so that the history remains accessible.

<!-- prettier-ignore -->
> [!NOTE]
> PR/feature branches should be short-lived, so make sure you remove both
> the remote (`git push origin :feature/branch`) and local PR/feature branch
> (`git branch -d feature/branch`).**

### `--force-with-lease` and `--force-if-includes`

It's important to use `--force-with-lease` together with `--force-if-includes`
when force-pushing rebased branches.

`--force-with-lease` alone can be defeated by background auto-fetches (common in
IDEs like LazyGit, VS Code, etc.) that update your remote-tracking branch
without you realizing it. When this happens, `--force-with-lease` thinks you've
seen the latest remote changes and allows the force-push, potentially
overwriting others' work.

`--force-if-includes` adds an extra safety check: it uses your reflog to verify
you've actually integrated remote changes into your local branch before allowing
the force-push.

**References:**

- https://github.com/jesseduffield/lazygit/issues/1668#issuecomment-1956201168
- https://github.com/jesseduffield/lazygit/issues/1668#issuecomment-1956549518
- https://stackoverflow.com/questions/65837109/when-should-i-use-git-push-force-if-includes

## Rebasing

When rebasing branches that contain merge commits (such as rebasing `staging`
itself), use `--rebase-merges` to preserve the existing merge commits from
feature branches. This is a safer rebasing approach that maintains the merge
structure rather than linearizing all commits.

```bash
git rebase --rebase-merges main
```

This is particularly useful when you need to rebase a staging branch that
contains multiple feature branch merges and you want to preserve that merge
history in the rebased result.

Note: You can use `--no-rebase-merges` to explicitly disable this behavior if
needed.

<!-- prettier-ignore -->
> [!TIP]
> You can configure this as the default rebase behavior with
> `git config --global rebase.rebaseMerges true` (sets `--rebase-merges` as
> the default for all rebase operations).

## Pull request review

Here's a useful emoji code you can use for verbose code reviews:
https://gist.github.com/pfleidi/4422a5cac5b04550f714f1f886d2feea

## Hotfixes to production

To be documented. The most important element is keeping `main`/`staging` with
exactly the same history.

## Optional squashing

I am not a fan of squashing, but when used with common sense it can be helpful.
If your feature branch is full of small commits that touch very few files/lines,
it makes more sense to squash them than to merge the whole history.

TL;DR

- `git checkout staging`
- `git merge feature/branch --squash` (there's no commit here yet, but changes
  are staged)
- `git commit -m "JIRA-1234: something done"` (JIRA-1234 or whatever references
  your PM tool of choice)
- `git push`
- `git push origin :feature/branch` (removes remote branch)
- `git branch -d feature/branch` (removes local branch)

## Commit messages

Text from https://github.blog/2011-09-06-shiny-new-commit-styles/:

**Always include a reference to the task (Jira, Trello, ClickUp) in the summary
or the description.**

**If at all possible, look for integration between the PM tool and the commit.**

```
Capitalized, short (50 chars or less) summary

More detailed explanatory text, if necessary. Wrap it to about 72 characters or
so. In some contexts, the first line is treated as the subject of an email and
the rest of the text as the body. The blank line separating the summary from the
body is critical (unless you omit the body entirely); tools like rebase can get
confused if you run the two together.

Write your commit message in the present tense: "Fix bug" and not "Fixed bug."
This convention matches up with commit messages generated by commands like `git
merge` and `git revert`.

Further paragraphs come after blank lines.

- Bullet points are okay, too
- Typically a hyphen or asterisk is used for the bullet, preceded by a single
  space, with blank lines in between, but conventions vary here
- Use a hanging indent
```

<!-- prettier-ignore -->
> [!TIP]
> I find **_50 chars or less_** too short. I normally use the
> [amazing GitSavvy Sublime Text plugin](https://github.com/timbrel/GitSavvy)
> that has a
> [sensible warning at +20 characters](https://github.com/timbrel/GitSavvy/blob/f2e6abd619558934de59bab9ebd0d750476798da/GitSavvy.sublime-settings#L134)
> making **70 characters** a good summary line length.

Furthermore, using [conventional commits][cc] can create a very nice changelog
from commit messages and also encourages you to [scope your commits
better][cc-scope].

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

From the [Conventional Commits specification][cc]:

> The commit contains the following structural elements, to communicate intent
> to the consumers of your library:
>
> - **fix:** a commit of the type `fix` patches a bug in your codebase (this
>   correlates with PATCH in Semantic Versioning).
> - **feat:** a commit of the type `feat` introduces a new feature to the
>   codebase (this correlates with MINOR in Semantic Versioning).
> - **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or
>   appends a `!` after the type/scope, introduces a breaking API change
>   (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be
>   part of commits of any type.
> - _types_ other than `fix:` and `feat:` are allowed, for example
>   [@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional)
>   (based on the
>   [Angular convention](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines))
>   recommends `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`,
>   `perf:`, `test:`, and others.
> - _footers_ other than `BREAKING CHANGE: <description>` may be provided and
>   follow a convention similar to
>   [git trailer format](https://git-scm.com/docs/git-interpret-trailers).
>
> Additional types are not mandated by the Conventional Commits specification,
> and have no implicit effect in Semantic Versioning (unless they include a
> BREAKING CHANGE). A scope may be provided to a commit's type, to provide
> additional contextual information and is contained within parentheses, e.g.,
> `feat(parser): add ability to parse arrays`.

[cc]: https://www.conventionalcommits.org/
[cc-scope]:
  https://www.conventionalcommits.org/en/v1.0.0/#what-do-i-do-if-the-commit-conforms-to-more-than-one-of-the-commit-types

Other useful readings:

- https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
- https://markus.oberlehner.net/blog/git-the-pedantic-way/
