return {
  "theprimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("harpoon"):setup()
  end,
  keys = {
    {
      "gha",
      function()
        require("harpoon"):list():append()
      end,
      desc = "[A]dd file to Harpoon",
    },
    {
      "ghh",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "[H]arpoon menu",
    },
    {
      "gh1",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "",
    },
    {
      "gh2",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "",
    },
    {
      "gh3",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "",
    },
    {
      "gh4",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "",
    },
    {
      "gh5",
      function()
        require("harpoon"):list():select(5)
      end,
      desc = "",
    },
    {
      "gh6",
      function()
        require("harpoon"):list():select(6)
      end,
      desc = "",
    },
  },
}
