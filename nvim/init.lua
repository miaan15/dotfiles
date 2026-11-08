vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true
vim.opt.termguicolors = true
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '?' }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 4
vim.o.confirm = true
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 1
vim.opt.path:append("**")
vim.opt.wildmenu = true

if vim.fn.has("win32") == 1 then
    local powershell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"

    vim.o.shell = powershell
    vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.o.shellredir = "-RedirectStandardOutput %s -NoNewWindow"
    vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s"
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
end

vim.schedule(function() vim.o.clipboard = "unnamedplus" end)
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set softtabstop=4")

vim.o.autoread = true
vim.cmd("autocmd FocusGained,BufEnter * :silent! checktime")

vim.opt.path:append("**")
vim.opt.wildignore:append({ "*/.git/*", "*/node_modules/*", "*/vendor/*", "*/build/*" })
vim.opt.wildmode = "longest:full,full"

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function()
        vim.opt_local.formatoptions:remove({ "r", "o" })
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function() vim.hl.on_yank() end,
})

local lsp_term_group = vim.api.nvim_create_augroup("LspTerminalToggle", { clear = true })

-- -- this shit is for windows cus it keep locking stuff while try to run
-- vim.api.nvim_create_autocmd("BufEnter", {
--     group = lsp_term_group,
--     callback = function(args)
--         local buftype = vim.bo[args.buf].buftype
--
--         if buftype == "terminal" then
--             for _, client in ipairs(vim.lsp.get_clients()) do
--                 client:stop()
--             end
--         else
--             local ft = vim.bo[args.buf].filetype
--             if ft == "c" or ft == "cpp" then
--                 vim.lsp.enable("clangd")
--             elseif ft == "odin" then
--                 vim.lsp.enable("ols")
--             end
--         end
--     end,
-- })

vim.api.nvim_create_user_command('TrimWhitespaces', function()
    local save_cursor = vim.api.nvim_win_get_cursor(0)
    local last_search = vim.fn.getreg('/')
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, save_cursor)
    vim.fn.setreg('/', last_search)
    vim.cmd('nohlsearch')
end, {})

_G.tg_term_buf = nil
vim.api.nvim_create_user_command('ToggleTerminal', function()
    if _G.tg_term_buf and vim.api.nvim_get_current_buf() == _G.tg_term_buf then
        vim.cmd("buffer #")
        return
    end

    if _G.tg_term_buf and vim.api.nvim_buf_is_valid(_G.tg_term_buf) then
        vim.api.nvim_win_set_buf(0, _G.tg_term_buf)
    else
        vim.cmd("terminal")
        _G.tg_term_buf = vim.api.nvim_get_current_buf()
        pcall(vim.api.nvim_buf_set_name, _G.tg_term_buf, "term_tg_")
    end

    vim.cmd("startinsert")
end, {})

vim.api.nvim_create_user_command("SplitSmart", function()
    local windows = vim.api.nvim_tabpage_list_wins(0)
    local current_window_count = #windows

    if current_window_count % 2 ~= 0 then vim.cmd("vsplit")
    else vim.cmd("split") end
end, {})

vim.api.nvim_create_user_command("LastBuffer", function()
    local alt_buf = vim.fn.bufnr('#')
    if alt_buf ~= -1 and vim.fn.buflisted(alt_buf) == 1 then
        vim.cmd('buffer #')
    else
        pcall(vim.cmd, 'bprevious')
    end
end, {})

vim.api.nvim_create_user_command("BufferMenu", function()
    local bufinfo = vim.fn.getbufinfo({ buflisted = 1 })
    local valid_bufs = {}

    for i, info in ipairs(bufinfo) do
        if info.loaded == 1 then
            table.insert(valid_bufs, info)
        end
    end

    table.sort(valid_bufs, function(a, b)
        return a.lastused > b.lastused
    end)

    if #valid_bufs > 0 then
        table.remove(valid_bufs, 1)
    end

    if #valid_bufs == 0 then
        print("No buffers open")
        return
    end

    local lines = {}
    local ordered_bufnrs = {}

    for _, info in ipairs(valid_bufs) do
        local name = vim.fn.fnamemodify(info.name, ":t")
        if name == "" then name = "[No Name]" end

        table.insert(lines, name)
        table.insert(ordered_bufnrs, info.bufnr)
    end

    local height = #lines + 1
    vim.cmd("botright " .. height .. "new")
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].filetype = "buffer_menu"

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].cursorline = true

    vim.keymap.set('n', '<CR>', function()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local target_buf = ordered_bufnrs[row]

        vim.cmd("bd!")

        if target_buf and vim.api.nvim_buf_is_valid(target_buf) then
            vim.api.nvim_set_current_buf(target_buf)
        end
    end, { buffer = buf, nowait = true })
end, {})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("trim-whitespaces-on-save", { clear = true }),
    pattern = "*",
    callback = function()
        if vim.bo.buftype ~= "" or not vim.bo.modifiable then
            return
        end
        vim.cmd("TrimWhitespaces")
    end,
})

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set("n", "<M-Down>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<M-Up>", "<cmd>m .-2<CR>==", { desc = "Move line up" })

vim.keymap.set("n", "<M-Left>", "<<", { desc = "Shift left" })
vim.keymap.set("n", "<M-Right>", ">>", { desc = "Shift right" })
vim.keymap.set("v", "<M-Left>", "<gv", { desc = "Shift left" })
vim.keymap.set("v", "<M-Right>", ">gv", { desc = "Shift right" })

vim.keymap.set('n', '<leader>b', '<cmd>BufferMenu<CR>', { desc = 'List and select buffer' })
vim.keymap.set('n', "<leader>x", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>,", "<cmd>LastBuffer<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<leader>f", ":e <C-R>=expand('%:p:h') . '/'<CR>", { desc = "Find find" })
vim.keymap.set("n", "<leader>F", ":find ", { desc = "Find find fuzzy" })

vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerminal<CR>", { desc = "Toggle Terminal" })

vim.keymap.set("n", "<leader>/", "<cmd>SplitSmart<CR>", { desc = "Split window smart" })

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Show line diagnostics" })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = "Line Diagnostics" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { -- Theme
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                custom_highlights = function(colors)
                    return {
                        ["Comment"]              = { fg = colors.green },
                        ["@function.builtin"]    = { link = "@function" },
                        ["@property"]            = { link = "@lsp.type.variable" },
                        ["@variable.parameter"]  = { link = "@lsp.type.variable" },
                        ["Macro"]                = { link = "Statement" },
                        ["Repeat"]               = { link = "Statement" },
                        ["Conditional"]          = { link = "Statement" },
                        ["Include"]              = { link = "Statement" },
                        ["Special"]              = { link = "Statement" },
                        ["PreProc"]              = { link = "Statement" },
                        ["Structure"]            = { link = "Type" },
                        ["String"]               = { link = "Number" },
                        ["Constant"]             = { link = "Number" },
                        ["Boolean"]              = { link = "Number" },
                        ["@lsp.type.enumMember"] = { link = "Number" },
                    }
                end,
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    { -- which-key
        "folke/which-key.nvim",
    },

    { -- LSP
        "neovim/nvim-lspconfig",
        config = function()
            -- c/c++
            vim.lsp.config("clangd", {
                filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                },
            })
            vim.lsp.enable("clangd")

            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
                callback = function(ev)
                    vim.keymap.set('n', 'grd', vim.lsp.buf.definition, { desc = "Go to Definition", buffer = ev.buf })
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover Documentation", buffer = ev.buf })
                    vim.keymap.set('n', 'grh', function()
                        local filter = { bufnr = ev.buf }
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
                    end, { desc = "Toggle Inlay Hints", buffer = ev.buf })
                end,
            })
        end,
    },

    { -- Explore
        'stevearc/oil.nvim',
        config = function()
            require("oil").setup({
                default_file_explorer = true,
                columns = {
                    { "permissions" },
                    { "size", align = "right" },
                    { "mtime", format = "%Y-%m-%d [%H:%M]" },
                },
                view_options = {
                    show_hidden = false,
                    is_hidden_file = function(name, bufnr)
                        return vim.endswith(name, ".meta")
                    end,
                },
            })
            vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open parent directory" })
        end
    },

    { -- Git Sign
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "-" },
                changedelete = { text = "~" },
                untracked = { text = "#" },
            },
            signs_staged = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "-" },
                changedelete = { text = "~" },
                untracked = { text = "#" },
            },
            signcolumn = true,
            numhl = false,
            linehl = false,
            word_diff = false,
            current_line_blame = false,
            current_line_blame_opts = { delay = 100 },
        },
    },
})
