return {
  {
    "3rd/image.nvim",
    -- Skip the build step: it tries to install the magick Lua rock, which the
    -- magick_cli processor doesn't need (LuaRocks is disabled in lazy.lua).
    build = false,
    opts = {
      -- Ghostty speaks the Kitty graphics protocol.
      backend = "kitty",
      -- Shell out to the Homebrew ImageMagick binary instead of using FFI bindings.
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" },
        },
      },
      max_height_window_percentage = 50,
      -- Hide images when switching to another tmux window; needs visual-activity off.
      tmux_show_only_in_active_window = true,
      -- Open image files directly as rendered images.
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
    },
  },
}
