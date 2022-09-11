
# imagine.nvim

Neovim plugin to integrate text-to-image models inside of neovim. A normal use case for this plugin is someone that is writing prose, which selects some text to be rendered as an image, and opened up to be enjoyed. For instance:

*A swirling wind demon fighting against a raging fire demon over the ocean, epic, digital art*:

![demon](./images/A_swirling_wind_demon_fighting_against_a_raging_fire_demon_over_the_ocean,_epic,_digital_art/seed_981604_00002.png)

TODO:
  - Table of contents

<!--
TODO: Add logo created via stable-diffusions
A robot in the pose of the statue The thinker by Auguste Rodin imagining things, cyberpunk:1.2, digital art, trending on artstation:

![robot_thinker](./images/robot_thinker.png)
-->


[Installation](# Installation)

## Installation

Installing this plugin is not a trivial matter, don't be discouraged. The installation features 3 stages. It assumes you have the `Nix` package manager installed. [Nix installation instructions](https://nixos.org/download.html).

### 1: Downloading stable-diffusions model weights (`.ckpt` file)

1. Request access to this [HuggingFace stable-diffusions repository](https://huggingface.co/CompVis/stable-diffusion-v1-4).
  - This will require logging in to HuggigFace or create an account, which requires a name and email.

2. Head to [this link](https://huggingface.co/CompVis/stable-diffusion-v-1-4-original) and in the section `Download the weights`, download the file called `sd-v1-4.ckpt`. This file will be refered to as the **weights file**, and we will get back to it later.

### 2: Clone fork of `stable-diffusions` repository

Original stable-diffusions uses `conda`, which is not good as a use for `nvim` plugins because we need to enter a conda environment via `conda-shell`. Instead we use a fork (maintained by yours truly) which uses a standard `requirements.txt` for python packages and non-python dependencies via [`nix`](https://nixos.org/) (no nix knowledge is required). **This should take care of nvidia drivers, C++ compilers needed for pytorch and every python dependency!**.

1. Clone fork of [stable-diffusion](https://github.com/Danielhp95/stable-diffusion):
  - `git clone https://github.com/Danielhp95/stable-diffusion`

2. Move **weights file** file to directory `stable-diffusion/ldm/models/stable-diffusion-v1/model.ckpt`:
  - `mv <path-to-weights-file> stable-diffusion/ldm/models/stable-diffusion-v1/model.ckpt`

3. **OPTIONAL**: Run command:

- `NIXPKGS_ALLOW_UNFREE=1 nix-shell default.nix --run "python optimizedSD/optimized_txt2img.py --prompt \"A robot testing itself\" "`

### 3: Installing neovim Plugin

Install pluing via your favourite plugin manager.  I personally recommend [`packer.nvim`](https://github.com/wbthomason/packer.nvim). These are the different configuration options.

```lua
use {'danielhp95/imagine.nvim',
     requires = {'nvim-lua/plenary.nvim',  -- Lua utility library used internally
                 'nvim-telescope/telescope.nvim' -- For selecting saved images
                },
     config = function() require("imagine").setup({
        path_to_executable = "<path-to-cloned-stable-diffusion>",
        cmd = "python optimizedSD/optimized_txt2img.py",
        visual_selection_keymap = "<leader>i",
        image_viewer = "imv",  -- Other alternatives: feh
        config = {
          model_config = "",
          prompt_extras = ", digital art"  -- Stylizes images
        }
       }
     end
   }
```

## Usage

For detailed documentation see the built-in [docs](./doc/imagine.txt).

### Commands

+ `Imagine <prompt>`: Calls text to image model with the given prompt. A terminal will open showing the creation process.
+ `ImagineRemember`: Opens telescope on the directory where results are kept. Selected item will be open in [`imv`](https://sr.ht/~exec64/imv/)
+ `ImagineOpenConfigFile`: Opens current config file for image creation.
+ `ImagineSetConfigFile <path-to-config-file>`: Sets a file given by `path-to-config-file` for the current session.

## Troubleshooting

Setting up this plugin is rather complex, so expect difficulties along the way. If your issue isn't listed here, open an issue on this repo.

**I am lacking Imagination, which prompts should I use?**

Be inspired by [Lexica](lexica.art), a compilation of inputs / outputs for these kind of models.

**Downloading Python dependencies failed and now they won't download again**

Destroy the `.venv/` directory and try again! It won't try to download dependencies again if that directory is present.

**No CUDA drivers found when running model**

Open an issue containing (1) the error message (2) The output of command `nvidia-smi` (3) Any information you might find relevant.

**I get a `JSONDecodeError` when running the model**

Could be related to a config file for the model for stable-diffusions. For unknown (potentially evil) reasons, running the model requires checking for updates on Hugging Face servers, which can download arbitrary files (scary). Some of these config files have proved to be malformed. [This thread helped me once](https://www.reddit.com/r/StableDiffusion/comments/xa1zbe/sd_stopped_working_not_a_valid_json_file_any/)
