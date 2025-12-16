# Deploying to GitHub

Follow these steps to publish the bcpredict package to GitHub.

## Prerequisites

- Git installed and configured with your username and email.
- A GitHub account (username: YifeiBelle).
- GitHub personal access token (PAT) with repo scope.

## Steps

1. **Create a new repository on GitHub**
   - Go to https://github.com/new
   - Repository name: `bcpredict`
   - Description: "R package for breast cancer diagnosis prediction"
   - Choose public or private.
   - Do NOT initialize with README, .gitignore, or license (we already have them).

2. **Initialize local Git repository**
   Open a terminal in the `bcpredict` directory and run:

   ```bash
   git init
   git add .
   git commit -m "Initial commit: bcpredict package"
   ```

3. **Add remote and push**
   ```bash
   git remote add origin https://github.com/YifeiBelle/bcpredict.git
   git branch -M main
   git push -u origin main
   ```

   If you use SSH:
   ```bash
   git remote add origin git@github.com:YifeiBelle/bcpredict.git
   ```

4. **Install the package from GitHub**
   After pushing, you can install the package directly:

   ```r
   remotes::install_github("YifeiBelle/bcpredict")
   ```

## Updating the package

If you make changes, repeat the add-commit-push cycle.

## Additional steps for package release

Consider creating a release tag:

```bash
git tag -a v0.1.0 -m "First release"
git push origin v0.1.0
```

## Troubleshooting

- If you encounter authentication issues, ensure your PAT is set up (e.g., via `gitcreds::gitcreds_set()`).
- If you have existing files on GitHub (like README), you may need to pull and merge first.

## Contact

For questions, contact Yifei Song (Yifei.Song23@student.xjtlu.edu.cn).