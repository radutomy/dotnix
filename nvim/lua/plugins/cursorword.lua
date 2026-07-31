return {
  {
    "nvim-mini/mini.cursorword",
    version = false,
    config = function()
      require("mini.cursorword").setup()
      vim.api.nvim_set_hl(0, "MiniCursorword", { link = "Visual" })
      vim.keymap.set("n", ">", "*", { desc = "Next Word" })
      vim.keymap.set("n", "<", "#", { desc = "Previous Word" })
    end,
  },
}
