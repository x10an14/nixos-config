{config, ...}:
{
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      pull.ff = "only";
      gpg.program = "gpg";

      alias = {
        wd = "diff --word-diff";
        tree = "log --graph --topo-order";
        list-files = "ls-tree --name-only";
        current-branch = "rev-parse --abbrev-ref HEAD";
        push-new-branch = "!git push --set-upstream origin $(git current-branch)";
        clean-deleted = "!git rm $(git ls-files --deleted)";
      };

      url = {
        "git@github.com:" = {
          insteadOf = [
            "gh:"
            "github:"
          ];
        };
        "git@gitlab.com:" = {
          insteadOf = [
            "gl:"
            "gitlab:"
          ];
        };
        "git@git.sr.ht:" = {
          insteadOf = [
            "sr.ht:"
          ];
        };
      };
    };
  };
}
