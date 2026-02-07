return {
	"neovim/nvim-lspconfig", -- still needed as a "bag of configs" for server definitions
	lazy = true, -- mason-lspconfig will ensure it's on runtimepath
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		{
			"mason-org/mason-lspconfig.nvim",
			opts = {
				ensure_installed = {
					"clangd",
					"pyright",
					"jsonls",
					"texlab",
					"lua_ls",
				},
				-- automatically calls vim.lsp.enable() for installed servers
				automatic_enable = true,
			},
		},
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			opts = {
				ensure_installed = {
					"stylua",
					"java-debug-adapter",
					"java-test",
				},
			},
		},
		{ "j-hui/fidget.nvim", opts = {} },
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		-- ── Keymaps on LspAttach ──────────────────────────────────────────
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
				map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
				map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

				-- Document highlight
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if
					client
					and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
				then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})
					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({
								group = "kickstart-lsp-highlight",
								buffer = event2.buf,
							})
						end,
					})
				end

				-- Toggle inlay hints
				if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		-- ── Capabilities (broadcast nvim-cmp to all servers) ─────────────
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		-- ── Server configs via vim.lsp.config ────────────────────────────
		-- The '*' key sets defaults for ALL servers
		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		vim.lsp.config("clangd", {})

		vim.lsp.config("pyright", {
			filetypes = { "python" },
			settings = {
				python = {
					inlayHints = {
						variableTypes = true,
						functionReturnTypes = true,
						parameterNames = {
							enabled = "all",
							suppressWhenArgumentMatchesName = false,
						},
					},
				},
			},
		})

		vim.lsp.config("jsonls", {
			filetypes = { "json" },
		})

		vim.lsp.config("texlab", {
			filetypes = { "tex", "bib" },
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})

		-- ── Julia LSP (not managed by Mason) ─────────────────────────────
		vim.lsp.config("julials", {
			capabilities = capabilities,
			cmd = {
				vim.fn.exepath("julia"),
				"--startup-file=no",
				"--history-file=no",
				"-e",
				[[
                    using LanguageServer
                    runserver()
                ]],
			},
		})
		vim.lsp.enable("julials")
	end,
}
