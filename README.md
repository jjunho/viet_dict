# viet_dict
>
> Built with [Elm Land](https://elm.land) 🌈

## Vietnamese Dictionary

This is a Vietnamese Chữ Nôm dictionary app built with Elm. It is a work in progress.
It is a simple search over the list of words found at [ChuNom.org](https://chunom.org/pages/standard-list/?max=2000&download=1).

## Features

- [X] Search for words in Vietnamese Quốc Ngữ and get the corresponding Chữ Nôm.
- [X] Search for words in Chữ Nôm and get the corresponding Vietnamese Quốc Ngữ.

## Local development

```bash
# Requires Node.js v18+ (https://nodejs.org)
npx elm-land server
```

## Building and using the app

Run `bash dist.sh` to build the app. The output will be in the `dist` folder.

The app can be used by opening [http://localhost:8080](http://localhost:8080) in a web browser.
