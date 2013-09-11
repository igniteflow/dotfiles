dotfiles
========

My dotfiles are stored here.  Linked up on new boxes using the wonderful [GNU Stow](https://www.gnu.org/software/stow/)

New installation:

    cd ~
    git clone git@github.com:igniteflow/dotfiles.git 
    sudo apt-get install stow
    cd dotfiles
    stow bash
    # ... stow each dir in dotfiles required
