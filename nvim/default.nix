{ pkgs, lib, ...}:

let 
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
            (fromGitHub "16ee9ae957db2142fb189f5f2556123e24c5b7fb" "master" "NeogitOrg/neogit")
            (fromGitHub "3dc498c9777fe79156f3d32dddd483b8b3dbd95f" "main" "sindrets/diffview.nvim")
            (fromGitHub "11a4d42244755505b66b15cd4496a150432eb5e3" "master" "rhysd/conflict-marker.vim")
            (fromGitHub "36ff7abb6b60980338344982ad4cdf03f7961ecd" "master" "mbbill/undotree")
            (fromGitHub "6ef8c54fb526bf3a0bc4efb0b2fe8e6d9a7daed2" "release" "lewis6991/gitsigns.nvim")
            (fromGitHub "0754163b9d070d4a99d60ecb45f060bc5f97e281" "release" "github/copilot.vim")
            (fromGitHub "5e50cc0e96e8a8ffc6fd10d627d65b8d1354b5da" "master" "lervag/vimtex")
            (fromGitHub "4a0f475aaef756702222bdd5b01e25f814f5691f" "master" "derekelkins/agda-vim")
            (fromGitHub "32236a8b376d9311dec9b5fe795ca99d32060b13" "master" "dyng/ctrlsf.vim")
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
            # nvim-spectre
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
           ${builtins.readFile ./init.lua}
       '';
     };
   };

}
