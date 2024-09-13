{ pkgs, lib, ...}:

let 
    imports =
      [ 
        <home-manager/nixos>
      ];

    fromGitHub = rev: ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
       pname = "${lib.strings.sanitizeDerivationName repo}";
       version = ref;
       src = builtins.fetchGit {
         url = "https://github.com/${repo}.git";
         ref = ref;
         rev = rev;
       };
    };
in
{

  home-manager.users.v0d1ch = { pkgs, ... }: {

     programs.neovim = {
       enable = true;
       viAlias = true;
       vimAlias = true;
       withNodeJs = true;
       plugins = with pkgs.vimPlugins; [
            nvim-lspconfig
            nvim-treesitter.withAllGrammars
            plenary-nvim
            # (fromGitHub "9316e40b915f92ea11102933630e799f58772f56" "master" "NeogitOrg/neogit")
            (fromGitHub "3be926866a6fdee86f53c13455c9b106f85ca3dc" "master" "NeogitOrg/neogit")
            nerdtree
            nerdcommenter
            awesome-vim-colorschemes
            catppuccin-nvim
            solarized
            vim-lastplace
            plenary-nvim
            direnv-vim
            telescope-nvim
            telescope-coc-nvim
            telescope_hoogle
            completion-nvim
            vim-nix
            vim-cool
            haskell-vim
            rust-tools-nvim
            nvim-lspconfig
            fzf-vim
            coc-nvim
            haskell-tools-nvim
            lazygit-nvim
            tokyonight-nvim
            project-nvim
            nvim-web-devicons
            lualine-nvim
            popup-nvim
            comment-nvim
            alpha-nvim
            nvim-spectre
            nvim-cursorline
            telescope-live-grep-args-nvim
            telescope-fzf-native-nvim
            vimtex
            coc-vimtex
            vim-latex-live-preview
            coc-rust-analyzer
            gitv
            rust-tools-nvim
            rust-vim
            diffview-nvim
            catppuccin-nvim
            kanagawa-nvim
       ];
       extraConfig = ''
         lua << EOF
           ${builtins.readFile /home/v0d1ch/code/dotfiles/nvim/init.lua}
       '';
     };
   };

}
