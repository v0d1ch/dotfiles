{opts, ...}:
{
  autoCmd = [
    {
      desc = "use vim for rebase conflicts";
      event = [ "FileType" ];
      pattern = [
        "gitrebase"
      ];
      command = "vnoremap <buffer> <localleader>p :s/\v^(pick\|reword\|edit\|squash\|fixup\|exec\|drop)/pick/<cr>";

    }
  #   {
  #     event = [ "BufEnter" "BufWinEnter" ];
  #     pattern = [ "*.md" "*.mdx" ];
  #     command = "MarkdownPreviewToggle";
  #   }
  ];


}
