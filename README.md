# toc

toc prints table of contents of markdown.

## Install

```sh
$ cargo install --locked --path .
```

## Usage

```sh
$ toc README.md
# toc
## Install
## Usage
## Vim plugin
## License
```

```sh
$ toc --vimgrep README.md
README.md:1:1:# toc
README.md:5:1:## Install
README.md:11:1:## Usage
README.md:30:1:## Vim plugin
README.md:35:1:## License
```

## Vim plugin

Toc provider for [vim-clap](https://github.com/liuchengxu/vim-clap).
Make `:Clap toc` available in markdown files.

## License

MIT
