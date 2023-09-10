# leetup.nvim
A neovim plugin for [Leetup](https://github.com/dragfire/leetup)! Leet it up!

### List Problems

![List problems](./assets/demo.gif?raw=true)

### Edit Problem

![Edit problems](./assets/edit.gif?raw=true)

# Usage
```lua
{
    "dragfire/leetup.nvim",
    dependencise = { "m00qek/baleia.nvim" }
}
```

## TODO:
- [x] Open floating window and display `leetup list`
- [x] Filter problems (support bare minimum)
- [x] Selecting a problem opens the generated file 
- [ ] Split window vertically instead of floating window
- [ ] Render list of problems in the split window
- [ ] Provide a way to get/build `leetup` binary from inside the plugin
- [ ] Make leetup configurable from init.lua (vimrc)
- [ ] ... more ...
