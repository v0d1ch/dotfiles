{ pkgs, lib, ...}:

let 
    imports =
      [ 
        <home-manager/nixos>
      ];

    fromGitHub = rev: ref: repo: pkgs.vimUtils.buildVimPlugin {
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
            (fromGitHub "ce0c369ccdba3f644a3b28f4c053421f435352c9" "master" "NeogitOrg/neogit")
            (fromGitHub "3dc498c9777fe79156f3d32dddd483b8b3dbd95f" "main" "sindrets/diffview.nvim")
            (fromGitHub "11a4d42244755505b66b15cd4496a150432eb5e3" "master" "rhysd/conflict-marker.vim")
            (fromGitHub "36ff7abb6b60980338344982ad4cdf03f7961ecd" "master" "mbbill/undotree")
            (fromGitHub "2c2463dbd82eddd7dbab881c3a62cfbfbe3c67ae" "main" "lewis6991/gitsigns.nvim")

            nvim-lspconfig
            nvim-treesitter.withAllGrammars
            plenary-nvim
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
