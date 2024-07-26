{pkgs, inputs, opts, ...}:
{

  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "ctrlsf";
      src = inputs.ctrlsf;
    })
  ];

}
